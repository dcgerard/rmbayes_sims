############################
## Fit updog on Shirasawa data
############################

# Number of threads to use for multithreaded computing. This must be
# specified in the command-line shell; e.g., to use 8 threads, run
# command
#
#  R CMD BATCH '--args nc=8' mca_updog.R
#
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  nc <- 1
} else {
  eval(parse(text = args[[1]]))
}
cat(nc, "\n")


library(updog)
library(future)
refmat <- as.matrix(read.csv(file = "./output/shir/shir_ref.csv", row.names = 1))
sizemat <- as.matrix(read.csv(file = "./output/shir/shir_size.csv", row.names = 1))

plan(multisession, workers = nc)
mout <- multidog(refmat = refmat, sizemat = sizemat, ploidy = 6, nc = NA, model = "s1", p1_id = "Xushu18")
plan("sequential")

saveRDS(object = mout, file = "./output/shir/shir_updog.RDS")
