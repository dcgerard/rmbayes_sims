library(hwep)
library(tidyr)
library(readr)

nrep <- 1000
paramdf <- expand_grid(seed = seq_len(nrep),
                       n = c(10, 100, 1000, 10000),
                       ploidy = c(4, 6, 8),
                       condition = c("null", "alt"))
paramdf$x <- vector(mode = "list", length = nrow(paramdf))
paramdf$bf <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$p <- rep(NA_real_, length.out = nrow(paramdf))

for (i in seq_len(nrow(paramdf))) {
  set.seed(paramdf$seed[[i]])

  if (paramdf$condition[[i]] == "null") {
    pvec <- rep(1, length.out = paramdf$ploidy[[i]] / 2 + 1)
    pvec <- pvec / sum(pvec)
    qvec <- stats::convolve(pvec, rev(pvec), type = "open")
  } else {
    qvec <- rep(1, length.out = paramdf$ploidy[[i]] + 1)
    qvec <- qvec / sum(qvec)
  }

  paramdf$x[[i]] <- c(stats::rmultinom(n = 1, size = paramdf$n[[i]], prob = qvec))

  paramdf$bf[[i]] <- rmbayes(nvec = paramdf$x[[i]], lg = TRUE)
  paramdf$p[[i]] <- log(rmlike(nvec = paramdf$x[[i]], thresh = 0)$p_rm)
}
write_csv(x = paramdf, file = "./output/large_samp/ldf.csv")
