library(hwep)

ndf <- read.csv("./output/shir/shir_nmat.csv", row.names = 1)
nmat <- round(as.matrix(ndf))
nloc <- nrow(nmat)

bfvec <- rep(NA_real_, length.out = nloc)
pvec <- rep(NA_real_, length.out = nloc)
for (i in seq_len(nloc)) {
  bfvec[[i]] <- rmbayes(nmat[i, ])
  pvec[[i]] <- log(rmlike(nvec = nmat[i, ], thresh = 0)$p_rm)
}
ndf$bf <- bfvec
ndf$p <- pvec

write.csv(x = ndf, file = "./output/shir/shir_bfdf.csv", row.names = FALSE, col.names = TRUE)
