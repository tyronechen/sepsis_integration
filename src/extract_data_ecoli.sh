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

#sed -r -e "s|Staphylococcus aureus|Escherichia coli|" -e "s|BPH2760|B36|" ../data/BPH2760.txt > ../data/B36.txt
#sed -r -e "s|Staphylococcus aureus|Escherichia coli|" -e "s|BPH2760|MS14384|" ../data/BPH2760.txt > ../data/MS14384.txt
#sed -r -e "s|Staphylococcus aureus|Escherichia coli|" -e "s|BPH2760|MS14385|" ../data/BPH2760.txt > ../data/MS14385.txt
#sed -r -e "s|Staphylococcus aureus|Escherichia coli|" -e "s|BPH2760|MS14386|" ../data/BPH2760.txt > ../data/MS14386.txt
#sed -r -e "s|Staphylococcus aureus|Escherichia coli|" -e "s|BPH2760|MS14387|" ../data/BPH2760.txt > ../data/MS14387.txt

# hold out MS14385
for i in B36.txt MS14384.txt MS14385.txt MS14386.txt MS14387.txt;
do
  while IFS=$'\t' read x y z;
  do 
    python extract_data.py ../data/multi_omics_master_heatmap_pivoted_table.tsv -sp "${x}" -st "${y}" -om "${z}";
  done < "../data/${i}"
done

date
exit 0
