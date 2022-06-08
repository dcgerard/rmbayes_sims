##################################
## Go through all possible values of x
##################################
library(hwep)
library(tibble)
library(tidyr)
library(readr)

paramdf <- expand_grid(n = c(5, 10),
                       ploidy = c(4, 6, 8))
paramdf$dfbf <- vector(mode = "list", length = nrow(paramdf))
for (iter in seq_len(nrow(paramdf))) {
  xmat <- hwep::all_multinom(n = paramdf$n[[iter]], k = paramdf$ploidy[[iter]] + 1)
  colnames(xmat) <- paste0("D", 0:paramdf$ploidy[[iter]])
  bfvec <- rep(NA_real_, length.out = nrow(xmat))
  pvec <- rep(NA_real_, length.out = nrow(xmat))
  for (i in seq_len(nrow(xmat))) {
    bfvec[[i]] <- rmbayes(nvec = xmat[i, ], lg = TRUE)
    pvec[[i]] <- log(rmlike(nvec = xmat[i, ], thresh = 0)$p_rm)
  }
  paramdf$dfbf[[iter]] <- tibble(as_tibble(xmat), bf = bfvec, p = pvec)
}
simdf <- unnest(paramdf, col = "dfbf")
write_csv(x = simdf, file = "./output/small_samp/bfp.csv")
