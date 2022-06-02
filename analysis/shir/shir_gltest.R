#############
## Test using genotype likelihoods
#############

library(updog)
library(hwep)

mout <- readRDS("./output/shir/shir_updog.RDS")

## Filter out monomorphic snps ----
mout <- filter_snp(mout, pmax(Pr_0, Pr_1, Pr_2, Pr_3, Pr_4, Pr_5, Pr_6) < 0.9)

## format genotype likelihoods ----
gl <- format_multidog(mout, varname = paste0("logL_", 0:6))

## Run hwep ----
nloc <- dim(gl)[[1]]
bfvec <- rep(NA_real_, length.out = nloc)
for (i in seq_len(nloc)) {
  bfvec[[i]] <- rmbayesgl(gl = gl[i, , ])
}

saveRDS(object = bfvec, file = "./output/shir/bf_gl.RDS")
