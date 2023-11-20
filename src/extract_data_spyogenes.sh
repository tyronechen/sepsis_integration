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

sed -r -e "s|Staphylococcus aureus|Streptococcus pyogenes|" -e "s|BPH2760|5448|" ../data/BPH2760.txt > ../data/5448.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pyogenes|" -e "s|BPH2760|HKU419|" ../data/BPH2760.txt > ../data/HKU419.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pyogenes|" -e "s|BPH2760|PS003|" ../data/BPH2760.txt > ../data/PS003.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pyogenes|" -e "s|BPH2760|PS006|" ../data/BPH2760.txt > ../data/PS006.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pyogenes|" -e "s|BPH2760|SP444|" ../data/BPH2760.txt > ../data/SP444.txt

# hold out PS003
for i in 5448.txt HKU419.txt PS003.txt PS006.txt SP444.txt;
do
  while IFS=$'\t' read x y z;
  do 
    python extract_data.py ../data/multi_omics_master_heatmap_pivoted_table.tsv -sp "${x}" -st "${y}" -om "${z}";
  done < "../data/${i}"
done

date
exit 0
