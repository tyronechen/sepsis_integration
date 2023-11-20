#!/bin/bash
#SBATCH --job-name=parse
#SBATCH --time=4:00:00
#SBATCH --mail-user=tyrone.chen@monash.edu
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8192
#SBATCH --cpus-per-task=1
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --output=parse.out

source /projects/lz25/tyronec/mambaforge-pypy3/etc/profile.d/mamba.sh
mamba activate /home/tyronec/lz25_scratch/tyronec/envs/sour

date

sed -r -e "s|Staphylococcus aureus|Klebsiella pneumoniae|" -e "s|BPH2760|AJ218|" ../data/BPH2760.txt > ../data/AJ218.txt
sed -r -e "s|Staphylococcus aureus|Klebsiella pneumoniae|" -e "s|BPH2760|KPC2|" ../data/BPH2760.txt > ../data/KPC2.txt

for i in AJ218.txt KPC2.txt;
do
  while IFS=$'\t' read x y z;
  do 
    python extract_data.py ../data/multi_omics_master_heatmap_pivoted_table.tsv -sp "${x}" -st "${y}" -om "${z}";
  done < "../data/${i}"
done

date
exit 0
