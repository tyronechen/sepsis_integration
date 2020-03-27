#!/usr/bin/R
# combine metabolomics, proteomics and transcriptomics data
# data originally from Bioplatforms Australia sepsis project (unpublished)
library(argparser, quietly=TRUE)
# library(mixOmics)
source(file="multiomics_sepsis.R")

parse_argv = function() {
  library(argparser, quietly=TRUE)
  p = arg_parser("Run DIABLO on multi-omics data")

  # Add command line arguments
  p = add_argument(p, "classes", help="sample information", type="character")
  p = add_argument(p, "--omics", help="paths to omics data", type="character", nargs=Inf)
  p = add_argument(p, "--cpus", help="number of cpus", type="int", default=2)
  p = add_argument(p, "--out", help="write RData object here", type="character")
  p = add_argument(p, "--dist", help="distance metric to use [max.dist, centroids.dist, mahalanobis.dist]", type="character")

  # Parse the command line arguments
  argv = parse_args(p)

  # Do work based on the passed arguments
  return(argv)
}

main = function() {
  argv = parse_argv()
  if (! exists(argv$dist)) {
    dist = argv$dist
  } else {
    dist = "centroids.dist"
  }
  print("Distance measure:")
  print(dist)

  options(warn=1)

  paths = argv$omics

  print("Paths to data:")
  # print(paths)
  # parse out identifiers coded within the file paths
  names = sapply(sapply(lapply(paths, strsplit, "/"), tail, 1), tail, 1)
  names = unname(lapply(sapply(names, strsplit, ".", fixed=TRUE), head, 1))
  names = unname(sapply(sapply(names, head, 1), strsplit, "_"))
  names = unlist(lapply(lapply(names, tail, -1), paste, collapse="_"))
  print("Omics data types (names follow SAMPLEID_OMICTYPE_OPTIONALFIELDS):")
  # print(names)

  data = lapply(paths, parse_data)
  names(data) <- names
  print(dim(data))
  print(names(data))

  # lapply(names, print)
  q()
  prot = parse_data(argv$proteome)# + 1
  tran = parse_data(argv$translatome)# + 1
  classes = parse_classes(argv$classes)

  data = list(proteome = prot, translatome = tran)
  design = create_design(data)

  # check dimension
  print(summary(classes))
  print("Y (classes):")
  print(classes)
  print("Design:")
  print(design)

  # NOTE: if you get tuning errors, disable this block and set ncomp manually
  tuned = tune_ncomp(data, classes, design)
  print("Parameters with lowest error rate:")
  tuned = tuned$choice.ncomp$WeightedVote["Overall.BER",]
  ncomp = tuned[which.max(tuned)]

  # ncomp = length(unique(classes))
  # ncomp = 10
  print("Components:")
  print(ncomp)
  keepx = tune_keepx(data, classes, ncomp, design, cpus=argv$cpus, dist=dist)
  print("keepx:")
  print(keepx)
  diablo = run_diablo(data, classes, ncomp, keepx, design)
  print("diablo design:")
  print(diablo$design)
  # selectVar(diablo, block = "proteome", comp = 1)$proteome$name
  plot_diablo(diablo)
  assess_performance(diablo, dist=dist)
  predict_diablo(diablo, data, classes)

  if (! exists(argv$out)) {
    print(paste("Saving diablo data to:", argv$out))
    save(classes, data, diablo, dist, file=argv$out)
  } else {
    print(paste("Saving diablo data to:", "./diablo.RData"))
    save(classes, data, diablo, dist, file="./diablo.RData")
  }
}

main()
