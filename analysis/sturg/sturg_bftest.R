## Test for random mating on Sturg data

nmat <- readRDS("./output/sturg/nmat_updog.RDS")
nloc <- nrow(nmat)
bfvec <- rep(NA_real_, length.out = nloc)
pvec <- rep(NA_real_, length.out = nloc)
for (i in seq_len(nloc)) {
  bfvec[[i]] <- rmbayes(nmat[i, ])
  pvec[[i]] <- rmlike(nvec = nmat[i, ], thresh = 0)$p_rm
}

hist(bfvec)
hist(pvec)
ks.test(x = pvec, y = qunif)

nmat[which.min(bfvec), ]

