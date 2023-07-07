#!/bin/bash
# given gene id regex, gtf file, obtain gene coordinates

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
if [ "$#" -eq 6 ]; then
  # correct number of arguments so we carry on
  echo "" > /dev/null
else
  echo "Usage: $0 <gene_ids_regex> <genome.fasta> <annotation.gtf> <start> <finish>"
  echo "Map gene ids to gene coordinates using regexp, then extract window"
  echo "You can specify >1 gene_id with the pipe separator"
  echo 'For example: gene_id_1|gene_id_2|...'
  exit 1
fi

# regular expression to match gene to id
# note that it extracts this pattern and removes everything else
# e.g EW[0-9]+_RS[0-9]+
regex=$1
# genome fasta file
fasta=$2
# annotation gtf file
gtf=$3
# index from TSS (if -ve takes upstream seqs)
start=$4
finish=$5
# outfile_path
outfile_path=$6

unique=$(date +"%T.%16N" | md5sum | cut -d ' ' -f1)

gtf2bed < ${gtf} | grep -P ${regex} | awk \
    -v start=${start} -v finish=${finish} -F'\t' 'BEGIN{OFS="\t"} { 
        $11=$2; $2=$11+start; $3=$11+finish; print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11
    }' > ".bed.tmp.${unique}"

gzip -d ${fasta} \
    && bedtools getfasta -s -bed .bed.tmp.${unique} -fi ${fasta/.gz} -fo ${outfile_path} \
    && rm ".bed.tmp.${unique}" \
    && gzip ${fasta/.gz}