#!/bin/bash
bash ../extract_windows_from_geneid.sh \
    'EW032_RS00675|EW032_RS04130|EW032_RS04145|EW032_RS04295|EW032_RS05520' \
    ../../data/Staphylococcus_aureus_BPH2760_Genome/GCF*BPH2760_genomic.fna.gz \
    ../../data/Staphylococcus_aureus_BPH2760_Genome/GCF*BPH2760_genomic.gtf \
    -60 20 \
    ../../results/BPH2760/genomic_seqs.fasta

bash ../extract_windows_from_geneid.sh \
    'EW032_RS00675|EW032_RS04130|EW032_RS04145|EW032_RS04295|EW032_RS05520' \
    ../../data/Staphylococcus_aureus_BPH2819_Genome/GCF*BPH2819_genomic.fna.gz \
    ../../data/Staphylococcus_aureus_BPH2819_Genome/GCF*BPH2819_genomic.gtf \
    -60 20 \
    ../../results/BPH2819/genomic_seqs.fasta

bash ../extract_windows_from_geneid.sh \
    'EW032_RS00675|EW032_RS04130|EW032_RS04145|EW032_RS04295|EW032_RS05520' \
    ../../data/Staphylococcus_aureus_BPH2900_Genome/GCF*BPH2900_genomic.fna.gz \
    ../../data/Staphylococcus_aureus_BPH2900_Genome/GCF*BPH2900_genomic.gtf \
    -60 20 \
    ../../results/BPH2900/genomic_seqs.fasta

bash ../extract_windows_from_geneid.sh \
    'EW032_RS00675|EW032_RS04130|EW032_RS04145|EW032_RS04295|EW032_RS05520' \
    ../../data/Staphylococcus_aureus_BPH2947_Genome/GCF*BPH2947_genomic.fna.gz \
    ../../data/Staphylococcus_aureus_BPH2947_Genome/GCF*BPH2947_genomic.gtf \
    -60 20 \
    ../../results/BPH2947/genomic_seqs.fasta

bash ../extract_windows_from_geneid.sh \
    'EW032_RS00675|EW032_RS04130|EW032_RS04145|EW032_RS04295|EW032_RS05520' \
    ../../data/Staphylococcus_aureus_BPH2986_Genome/GCF*BPH2986_genomic.fna.gz \
    ../../data/Staphylococcus_aureus_BPH2986_Genome/GCF*BPH2986_genomic.gtf \
    -60 20 \
    ../../results/BPH2986/genomic_seqs.fasta