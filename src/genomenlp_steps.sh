#!/bin/bash
# genomenlp pipeline

# tokenise and create dataset
bash tokenise.sh BPH2760 8000 is_overlap -60 20 21 101
bash tokenise.sh BPH2819 8000 is_overlap -60 20 21 101
bash tokenise.sh BPH2900 8000 is_overlap -60 20 21 101
bash tokenise.sh BPH2947 8000 is_overlap -60 20 21 101
bash tokenise.sh BPH2986 8000 is_overlap -60 20 21 101

# run sweeps and training
bash gbert.base.slurm BPH2760 8000 is_overlap -60 20 21 101
bash gbert.base.slurm BPH2819 8000 is_overlap -60 20 21 101
bash gbert.base.slurm BPH2900 8000 is_overlap -60 20 21 101
bash gbert.base.slurm BPH2947 8000 is_overlap -60 20 21 101
bash gbert.base.slurm BPH2986 8000 is_overlap -60 20 21 101

# interpret
for i in BPH2760 BPH2819 BPH2900 BPH2947 BPH2986; do  echo $i; ls ../results/$i; done

# extract promoter regions of genes of interest
bash extract_windows_from_geneid.sh 'EW032_RS00675|EW032_RS04130|EW032_RS04145|EW032_RS04295|EW032_RS05520' ../data/Staphylococcus_aureus_BPH2760_Genome/GCF*BPH2760_genomic.fna.gz ../data/Staphylococcus_aureus_BPH2760_Genome/GCF*BPH2760_genomic.gtf -60 20 ../results/BPH2760/genomic_seqs.fasta
bash extract_windows_from_geneid.sh 'EW030_RS00705|EW030_RS00740|EW030_RS06895|EW030_RS07575|EW030_RS10880' ../data/Staphylococcus_aureus_BPH2819_Genome/GCF*BPH2819_genomic.fna.gz ../data/Staphylococcus_aureus_BPH2819_Genome/GCF*BPH2819_genomic.gtf -60 20 ../results/BPH2819/genomic_seqs.fasta
bash extract_windows_from_geneid.sh 'EW029_RS00795|EW029_RS05910|EW029_RS11320|EW029_RS11425|EW029_RS13620' ../data/Staphylococcus_aureus_BPH2900_Genome/GCF*BPH2900_genomic.fna.gz ../data/Staphylococcus_aureus_BPH2900_Genome/GCF*BPH2900_genomic.gtf -60 20 ../results/BPH2900/genomic_seqs.fasta
bash extract_windows_from_geneid.sh 'EW033_RS03940|EW033_RS03950|EW033_RS03960|EW033_RS04890|EW033_RS04895' ../data/Staphylococcus_aureus_BPH2947_Genome/GCF*BPH2947_genomic.fna.gz ../data/Staphylococcus_aureus_BPH2947_Genome/GCF*BPH2947_genomic.gtf -60 20 ../results/BPH2947/genomic_seqs.fasta
bash extract_windows_from_geneid.sh 'EW031_RS02185|EW031_RS12050|EW031_RS12150|EW031_RS13440|EW031_RS14390' ../data/Staphylococcus_aureus_BPH2986_Genome/GCF*BPH2986_genomic.fna.gz ../data/Staphylococcus_aureus_BPH2986_Genome/GCF*BPH2986_genomic.gtf -60 20 ../results/BPH2986/genomic_seqs.fasta

# this uses the interpret module of genomenlp to highlight regions of interest
interpret tyagilab/BPH2760/hre4vky3 ../results/BPH2760/genomic_seqs.fasta -o ../results/BPH2760/hre4vky3 -l PROMOTER GENIC
interpret tyagilab/BPH2819/p7jagh3i ../results/BPH2819/genomic_seqs.fasta -o ../results/BPH2819/p7jagh3i -l PROMOTER GENIC
interpret tyagilab/BPH2900/uctfamte ../results/BPH2900/genomic_seqs.fasta -o ../results/BPH2900/uctfamte -l PROMOTER GENIC
interpret tyagilab/BPH2947/2rtvzqig ../results/BPH2947/genomic_seqs.fasta -o ../results/BPH2947/2rtvzqig -l PROMOTER GENIC
Interpret tyagilab/BPH2986/a0kzfxp8 ../results/BPH2986/genomic_seqs.fasta -o ../results/BPH2986/a0kzfxp8 -l PROMOTER GENIC
