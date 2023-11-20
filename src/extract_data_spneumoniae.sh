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

sed -r -e "s|Staphylococcus aureus|Streptococcus pneumoniae|" -e "s|BPH2760|180\/15|" ../data/BPH2760.txt > ../data/180_15.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pneumoniae|" -e "s|BPH2760|180\/2|" ../data/BPH2760.txt > ../data/180_2.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pneumoniae|" -e "s|BPH2760|4496|" ../data/BPH2760.txt > ../data/4496.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pneumoniae|" -e "s|BPH2760|4559|" ../data/BPH2760.txt > ../data/4559.txt
sed -r -e "s|Staphylococcus aureus|Streptococcus pneumoniae|" -e "s|BPH2760|947|" ../data/BPH2760.txt > ../data/947.txt

# hold out 4496
for i in 180_15.txt 180_2.txt 4496.txt 4559.txt 947.txt;
do
  while IFS=$'\t' read x y z;
  do 
    python extract_data.py ../data/multi_omics_master_heatmap_pivoted_table.tsv -sp "${x}" -st "${y}" -om "${z}";
  done < "../data/${i}"
done

date
exit 0
