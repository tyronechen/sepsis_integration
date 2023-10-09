#!/bin/bash
NCPU=24
NCOMP=0  # 0 infers
scripts_dir="./"
infile_dir="../results/"
outfile_dir="../results/"
src="Rscript"
run="run_pipeline.R"  # from multiomics pipeline

SPECIES="Staphylococcus_aureus"
STRAIN="BPH2760"
INFO_M1="Metabolomics_GC_MS"
INFO_P1="Proteomics_MS1_DDA"
INFO_T1="RNA_Seq"

## preprocessing steps for reference only
# (printf "\t0\n"; cat ${scripts_dir}/${SPECIES}_${STRAIN}_${INFO_M1}/${STRAIN}_map.tsv \
#    ${scripts_dir}/${SPECIES}_${STRAIN}_${INFO_P1}/${STRAIN}_map.tsv \
#    ${scripts_dir}/${SPECIES}_${STRAIN}_${INFO_T1}/${STRAIN}_map.tsv) > ${STRAIN}_info_all.tsv
#
# (printf "\t0\n"; cat ${scripts_dir}/${SPECIES}_${STRAIN}_${INFO_T1}/${STRAIN}_map.tsv) > ${STRAIN}_info_all.tsv

time ${src} ${run} \
  --classes ${STRAIN}_info_all.tsv \
  --data ${scripts_dir}/${SPECIES}_${STRAIN}_${INFO_M1}/${STRAIN}.tsv \
         ${scripts_dir}/${SPECIES}_${STRAIN}_${INFO_P1}/${STRAIN}.tsv \
         ${scripts_dir}/${SPECIES}_${STRAIN}_${INFO_T1}/${STRAIN}.tsv \
  --data_names ${INFO_M1} ${INFO_P1} ${INFO_T1} \
  --ncpus ${NCPU} \
  --icomp 12 \
  --pcomp 10 \
  --plsdacomp 2 \
  --splsdacomp 2 \
  --diablocomp 2 \
  --dist_plsda "centroids.dist" \
  --dist_splsda "centroids.dist" \
  --dist_diablo "centroids.dist" \
  --cross_val "Mfold" \
  --cross_val_folds 5 \
  --cross_val_nrepeat 50 \
  --corr_cutoff 0.1 \
  --outfile_dir ${outfile_dir}/${SPECIES}_${STRAIN} \
  --contrib "max" \
  --progress_bar

date
exit 0
