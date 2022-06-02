######################
## Get genotype estimates from updog output
######################

library(updog)
mout <- readRDS("./output/shir/shir_updog.RDS")

## Filter out monomorphic snps ----
mout <- filter_snp(mout, pmax(Pr_0, Pr_1, Pr_2, Pr_3, Pr_4, Pr_5, Pr_6) < 0.9)

## Get nmat using posterior mode genotypes ----
# get_nvec <- function(x, ploidy) {
#   table(c(x, 0:ploidy)) - 1
# }
#
# genomat <- format_multidog(mout, varname = "geno")
# nmat_geno <- t(apply(genomat, 1, get_nvec, ploidy = 6))

## nmat using posterior counts ----
postarray <- format_multidog(mout, varname = paste0("Pr_", 0:6))
nmat_post <- apply(postarray, c(1, 3), sum, na.rm = TRUE)
colnames(nmat_post) <- 0:6

write.csv(x = nmat_post, file = "./output/shir/shir_nmat.csv")
