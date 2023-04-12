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
if [ "$#" -eq 3 ] || [ "$#" -eq 4 ] ; then
  # correct number of arguments so we carry on
  echo "" > /dev/null
else
  echo "Usage: $0 <genome.fasta> <annotation.gtf> <length_upstream_of_tss> [cpu]"
  echo "Extract a range of sequences upstream of the TSS, writeout as a bed file"
  exit 1
fi

# genome fasta file
genome=$1
# annotation gtf file
i=$2
# length upstream of TSS
len=$3
cpu=$4

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
    awk -v len=${len_real} -F'\t' 'BEGIN{OFS="\t"} { $3=$2; $2=$2-len ; print }' > \
    ${i}.${len_name}.bed.tmp
else
  len_real=${len}
  len_name=${len}  
  gtf2bed < ${i} | \
    awk -v len=${len_real} -F'\t' 'BEGIN{OFS="\t"} { $3=$2+len+1; $2=$2+1 ; print }' > \
    ${i}.${len_name}.bed.tmp
fi

# offset from TSS to mine for information-rich regions
echo bedops --range -${len_real}:-${len_real} --everything ${i}.${len_name}.bed.tmp \
  ${i}.${len_name}.bed
bedops --range -${len_real}:-${len_real} --everything ${i}.${len_name}.bed.tmp > \
  ${i}.${len_name}.bed

if (( $len < 0 )); then
  # it is possible that this may overlap into genic regions but informative
  # specifically, we are only interested in the overlaps for the -ve (upstream) case
  echo bedops --element-of 1 ${i}.${len_name}.bed.tmp ${i}.${len_name}.bed \
    ${i}.${len_name}.bed.overlap
  bedops --element-of 1 ${i}.${len_name}.bed.tmp ${i}.${len_name}.bed > \
    ${i}.${len_name}.bed.overlap
  wc -l ${i} ${i}.${len_name}.bed ${i}.${len_name}.bed.overlap
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