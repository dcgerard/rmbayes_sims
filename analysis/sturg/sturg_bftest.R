## Test for random mating on Sturg data
library(hwep)
nmat <- readRDS("./output/sturg/nmat_updog.RDS")
nloc <- nrow(nmat)
bfvec <- rep(NA_real_, length.out = nloc)
pvec <- rep(NA_real_, length.out = nloc)
for (i in seq_len(nloc)) {
  bfvec[[i]] <- rmbayes(nmat[i, ])
  pvec[[i]] <- log(rmlike(nvec = nmat[i, ], thresh = 0)$p_rm)
}

ndf <- as.data.frame(nmat)
ndf$bf <- bfvec
ndf$p <- pvec

write.csv(x = ndf, file = "./output/sturg/sturg_bfdf.csv", row.names = TRUE)
