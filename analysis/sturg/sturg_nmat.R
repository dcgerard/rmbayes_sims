# Number of threads to use for multithreaded computing. This must be
# specified in the command-line shell; e.g., to use 8 threads, run
# command
#
#  R CMD BATCH '--args nc=8' sims.R
#
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  nc <- 1
} else {
  eval(parse(text = args[[1]]))
}
cat(nc, "\n")

library(tidyverse)
library(updog)
library(future)

# altCounts_dryad and refCounts_dryad are loaded
load(file = "./data/sturg/8n_12n_sturgeon_readCounts.rda")
stopifnot(rownames(altCounts_dryad) == rownames(refCounts_dryad))
stopifnot(colnames(altCounts_dryad) == colnames(refCounts_dryad))

## 100% subsample (keep all reads) and presumed ploidy = 4 (ancestral = 8)
ind_keep <- str_detect(string = rownames(altCounts_dryad), pattern = "100_8N$")
refmat <- t(refCounts_dryad[ind_keep, ])
altmat <- t(altCounts_dryad[ind_keep, ])

sizemat <- refmat + altmat

future::plan(multisession, workers = nc)
uout <- multidog(refmat = refmat, sizemat = sizemat, ploidy = 4)
future::plan("sequential")

genomat <- format_multidog(x = uout, varname = "geno")

get_nvec <- function(x, ploidy) {
  table(c(x, 0:ploidy)) - 1
}

nmat <- t(apply(genomat, 1, get_nvec, ploidy = 4))

## Write everything
saveRDS(object = nmat, file = "./output/sturg/nmat_updog.RDS")
saveRDS(object = nmat, file = "./output/sturg/nmat_delo.RDS")
saveRDS(object = uout, file = "./output/sturg/sturg_updog.RDS")
