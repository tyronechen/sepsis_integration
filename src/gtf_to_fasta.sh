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
if [ "$#" -eq 3 ] || [ "$#" -eq 4 ] || [ "$#" -eq 5 ]; then
  # correct number of arguments so we carry on
  echo "" > /dev/null
else
  echo "Usage: $0 <genome.fasta> <annotation.gtf> <length_upstream_of_tss> [cpu] [--keep-overlaps]"
  echo "Extract a range of sequences upstream of the TSS, writeout as a bed file"
  exit 1
fi

# genome fasta file
genome=$1
# annotation gtf file
i=$2
# length from TSS (if -ve takes upstream seqs)
len=$3
# number of cpus needed
cpu=$4
# discard overlapping regions by default
keep_overlaps=$5

# if cpu not provided set to 1
if [ -z "$cpu" ]; then
    cpu=1
fi

# unzip
echo ${genome}
gzip -dv ${genome}

# get rid of anything that goes off the end of the chromosome
echo ${i} ${i}.${len}.bed.tmp

# want to keep the file name as negative, but the actual input requires positive integers
if (( $len < 0 )); then
  len_real=${len#?}
  len_name=${len}
  gtf2bed < ${i} | \
    awk -v len=${len_real} -F'\t' '{if($2<=len) next; if($2) print}' | \
    awk -v len=${len_real} -F'\t' 'BEGIN{OFS="\t"} { $3=$2-1; $2=$2-len-1 ; print }' > \
    ${i}.${len_name}.bed.tmp
else
  len_real=${len}
  len_name=${len}  
  gtf2bed < ${i} | \
    awk -v len=${len_real} -F'\t' 'BEGIN{OFS="\t"} { $3=$2+len+1; $2=$2+1 ; print }' > \
    ${i}.${len_name}.bed.tmp
fi

# NOTE: REF ONLY DO NOT USE, REDUNDANT WITH ABOVE
# offset from TSS to mine for information-rich regions
# echo bedops --range -${len_real}:-${len_real} --everything ${i}.${len_name}.bed.tmp \
#   ${i}.${len_name}.bed
# bedops --range -${len_real}:-${len_real} --everything ${i}.${len_name}.bed.tmp > \
#   ${i}.${len_name}.bed

if (( $len < 0 )); then
  # it is possible that this may overlap into genic regions but informative
  # specifically, we are only interested in the overlaps for the -ve (upstream) case
  # if we want to do this, we need the original coordinates of all genes
  echo gtf2bed ${i} ${i}.bed.tmp
  gtf2bed < ${i} > ${i}.bed.tmp
  echo bedops --element-of 1 ${i}.${len_name}.bed.tmp ${i}.bed.tmp \
    ${i}.${len_name}.bed.overlap
  bedops --element-of 1 ${i}.${len_name}.bed.tmp ${i}.bed.tmp > \
    ${i}.${len_name}.bed.overlap
  wc -l ${i}.bed.tmp ${i}.${len_name}.bed.tmp ${i}.${len_name}.bed.overlap
  if [[ "$keep_overlaps" == '--keep-overlaps' ]]; then
    echo "Retain overlaps in file"
  else
    echo "Remove overlaps in file, final count of non-overlapping regions:"
    bedtools subtract -A -a ${i}.${len_name}.bed.tmp -b ${i}.${len_name}.bed.overlap > \
      ${i}.${len_name}.bed.tmp.tmp
    mv ${i}.${len_name}.bed.tmp.tmp ${i}.${len_name}.bed.tmp
    wc -l ${i}.${len_name}.bed.tmp
  fi
else
  echo "Extracting downstream from TSS, gene overlap stats not relevant"
fi

# extract the seqs we need, reverse complementing reverse strands
echo bedtools getfasta -s -bed ${i}.${len_name}.bed.tmp -fi ${genome/.gz} -fo ${i}.${len_name}.fasta
bedtools getfasta -s -bed ${i}.${len_name}.bed.tmp -fi ${genome/.gz} -fo ${i}.${len_name}.fasta
rm ${i}.${len_name}.bed.tmp

# unzip
echo ${genome/.gz}
gzip -v ${genome/.gz}

python convert_input.py ${i}.${len_name}.fasta \
  -t ${cpu} \
  -o ${i}.${len_name}.bed \
  -s 100000 \
  -i

gzip ${i}.${len_name}.fasta