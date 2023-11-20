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
sed -r -e "s|Staphylococcus aureus|Klebsiella variicola|" -e "s|BPH2760|03-311-0071|" ../data/BPH2760.txt > ../data/03-311-0071.txt
sed -r -e "s|Staphylococcus aureus|Klebsiella variicola|" -e "s|BPH2760|04153260899A|" ../data/BPH2760.txt > ../data/04153260899A.txt
sed -r -e "s|Staphylococcus aureus|Klebsiella variicola|" -e "s|BPH2760|AJ055|" ../data/BPH2760.txt > ../data/AJ055.txt
sed -r -e "s|Staphylococcus aureus|Klebsiella variicola|" -e "s|BPH2760|AJ292|" ../data/BPH2760.txt > ../data/AJ292.txt

# hold out AJ055
for i in 03-311-0071.txt 04153260899A.txt AJ055.txt AJ292.txt;
do
  while IFS=$'\t' read x y z;
  do 
    python extract_data.py ../data/multi_omics_master_heatmap_pivoted_table.tsv -sp "${x}" -st "${y}" -om "${z}";
  done < "../data/${i}"
done

date
exit 0
