#!/bin/bash
# run gtf -> bed -> fasta pipeline

# dependency checks (note that this does not check version)
DEPENDENCIES=("gtf2bed" "bedops" "python" "samtools")

for d in "${DEPENDENCIES[@]}"; do
  type ${d} > /dev/null 2>&1
  if [ $? -eq 1 ]; then
      echo "Error: $d is not installed." >&2
      exit 1
  fi
done

# we expect fasta/gz, gtf and coords in integer format
if [ "$#" -eq 4 ] || [ "$#" -eq 5 ] || [ "$#" -eq 6 ]; then
  # correct number of arguments so we carry on
  echo "" > /dev/null
else
  echo "Usage: $0 <genome.fasta> <annotation.gtf> <start> <finish> [cpu] [--keep-overlaps]"
  echo "Extract a range of sequences relative to the TSS, write out as bed and fasta files"
  exit 1
fi

# genome fasta file
genome=$1
# annotation gtf file
i=$2
# index from TSS (if -ve takes upstream seqs)
start=$3
finish=$4
# number of cpus needed
cpu=$5
# discard overlapping regions by default
keep_overlaps=$6

# if cpu not provided set to 1
if [ -z "$cpu" ]; then
    cpu=1
fi

# unzip
echo ${genome}
gzip -dv ${genome}

# extract window, get rid of anything that goes off the end of the chromosome
# note that this also deletes genes with shorter length than selected window
echo ${i} ${i}.${start}:${finish}.bed.tmp
gtf2bed < ${i} | \
  awk -v start=${start} -v finish=${finish} -F'\t' 'BEGIN{OFS="\t"} { 
    $11=$3-$2; $3=$2+finish; $2=$2+start; if ($11>finish-start && $2>0) print 
    }' | \
  cut -f1-10 > ${i}.${start}:${finish}.bed.tmp

# if [[ "${keep_overlaps#--}" -eq 'keep-overlaps' ]]; then
#   echo "Retain overlaps in file"
#   echo ${keep_overlaps#--}
# fi
if [[ -z "${keep_overlaps}" ]]; then
  overlap='no_overlap'
  echo "Remove overlaps"
  if [ "$start" -lt "0" ] && [ "$finish" -gt "0" ]; then
    echo "Remove self-overlapping genic regions in file"
    # to compare overlap, we subtract the genic region if present in index
    # here, genic region refers to the same gene only (SELF overlaps) 
    mv ${i}.${start}':'${finish}.bed.tmp ${i}.${start}':'${finish}.bed.tmp.tmp
    awk -v start=${start} -v finish=${finish} -F'\t' \
      'BEGIN{OFS="\t"} {$3=$3-finish; print}' \
      ${i}.${start}':'${finish}.bed.tmp.tmp > ${i}.${start}':'${finish}.bed.tmp
    rm ${i}.${start}':'${finish}.bed.tmp.tmp 
  fi
  # now we remove overlaps where the region extends into OTHER genes
  echo gtf2bed ${i} ${i}.bed.tmp
  gtf2bed < ${i} > ${i}.bed.tmp
  echo bedops --element-of 1 ${i}.${start}:${finish}.bed.tmp ${i}.bed.tmp \
    ${i}.${start}:${finish}.bed.overlap
  bedops --element-of 1 ${i}.${start}:${finish}.bed.tmp ${i}.bed.tmp > \
    ${i}.${start}:${finish}.bed.overlap
  wc -l ${i}.bed.tmp ${i}.${start}:${finish}.bed.tmp \
    ${i}.${start}:${finish}.bed.overlap
  echo "Final count of non-overlapping regions:"
  echo bedtools subtract -A -a ${i}.${start}:${finish}.bed.tmp \
    -b ${i}.${start}:${finish}.bed.overlap \
    ${i}.${start}:${finish}.bed.tmp.tmp
  bedtools subtract -A -a ${i}.${start}:${finish}.bed.tmp \
    -b ${i}.${start}:${finish}.bed.overlap > \
    ${i}.${start}:${finish}.bed.tmp.tmp
  mv ${i}.${start}:${finish}.bed.tmp.tmp \
    ${i}.${start}:${finish}.${overlap}.bed.tmp
  wc -l ${i}.${start}:${finish}.${overlap}.bed.tmp
  if [ "$finish" -gt "0" ]; then
    # restore the original file, otherwise it will only be upstream of TSS
    mv ${i}.${start}:${finish}.${overlap}.bed.tmp \
      ${i}.${start}:${finish}.${overlap}.bed.tmp.tmp
    awk -v finish=${finish} -F'\t' 'BEGIN{OFS="\t"} {$3=$3+finish; print}' \
      ${i}.${start}:${finish}.${overlap}.bed.tmp.tmp > \
      ${i}.${start}:${finish}.${overlap}.bed.tmp
    rm ${i}.${start}:${finish}.${overlap}.bed.tmp.tmp 
  fi
else
  echo "Retain overlaps in file"
  overlap='is_overlap'
  mv ${i}.${start}:${finish}.bed.tmp ${i}.${start}:${finish}.${overlap}.bed.tmp
fi

# extract the seqs we need, reverse complementing reverse strands
echo bedtools getfasta -s -bed ${i}.${start}:${finish}.${overlap}.bed.tmp \
  -fi ${genome/.gz} -fo ${i}.${start}:${finish}.${overlap}.fasta
bedtools getfasta -s -bed ${i}.${start}:${finish}.${overlap}.bed.tmp \
  -fi ${genome/.gz} -fo ${i}.${start}:${finish}.${overlap}.fasta
rm ${i}.${start}:${finish}.${overlap}.bed.tmp

# unzip
echo ${genome/.gz}
gzip -v ${genome/.gz}

python /projects/lz25/tyronec/repos/sepsis_integration/src/convert_input.py \
  ${i}.${start}:${finish}.${overlap}.fasta \
  -t ${cpu} \
  -o ${i}.${start}:${finish}.${overlap}.bed \
  -s 100000 \
  -i

echo "Overriding ${i}.${start}:${finish}.${overlap}.fasta.gz if exists!"
gzip -f ${i}.${start}:${finish}.${overlap}.fasta