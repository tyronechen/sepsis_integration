#!/usr/bin/R
# combine metabolomics, proteomics and transcriptomics data
# data originally from Bioplatforms Australia sepsis project (unpublished)
library(argparser, quietly=TRUE)
# library(mixOmics)
source(file="multiomics_sepsis.R")

parse_argv = function() {
  p = arg_parser("Use predicted diablo model")

  # Add command line arguments
  p = add_argument(p, "data", help="load RData object", type="character")

  # Parse the command line arguments
  argv = parse_args(p)

  # Do work based on the passed arguments
  return(argv)
}

main = function() {
  argv = parse_argv()
  load(argv$data)
  plot_diablo(diablo)
  assess_performance(diablo, dist=dist)
  predict_diablo(diablo, data, classes)
}

main()
