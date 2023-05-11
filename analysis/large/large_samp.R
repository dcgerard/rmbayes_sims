library(hwep)
library(tidyr)
library(readr)
library(bench)

nrep <- 1000
paramdf <- expand_grid(seed = seq_len(nrep),
                       n = c(10, 100, 1000),
                       ploidy = c(4, 6, 8),
                       condition = c("null", "alt"))
paramdf$x <- vector(mode = "list", length = nrow(paramdf))
paramdf$bf <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$bf_time <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$p <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$p_time <- rep(NA_real_, length.out = nrow(paramdf))

## For sensativity analysis
paramdf$bf_low <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$bf_high <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$bf_weird <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$bf_allo <- rep(NA_real_, length.out = nrow(paramdf))

for (i in seq_len(nrow(paramdf))) {
  set.seed(paramdf$seed[[i]])
  cat("Iteration:", i, " / ", nrow(paramdf), "\n")

  if (paramdf$condition[[i]] == "null") {
    pvec <- rep(1, length.out = paramdf$ploidy[[i]] / 2 + 1)
    pvec <- pvec / sum(pvec)
    qvec <- stats::convolve(pvec, rev(pvec), type = "open")
  } else if (paramdf$condition[[i]] == "alt") {
    qvec <- rep(1, length.out = paramdf$ploidy[[i]] + 1)
    qvec <- qvec / sum(qvec)
  }

  paramdf$x[[i]] <- c(stats::rmultinom(n = 1, size = paramdf$n[[i]], prob = qvec))

  paramdf$bf_time[[i]] <- as.numeric(bench::system_time(
    paramdf$bf[[i]] <- rmbayes(nvec = paramdf$x[[i]], lg = TRUE)
  )[[2]])

  paramdf$p_time[[i]] <- as.numeric(bench::system_time(
    paramdf$p[[i]] <- log(rmlike(nvec = paramdf$x[[i]], thresh = 0)$p_rm)
  )[[2]])

  ## Sensitivity analysis
  ngam <- paramdf$ploidy[[i]] / 2 + 1
  alpha <- rep(1 / 2, ngam)
  beta <- hwep:::beta_from_alpha(alpha = alpha)
  paramdf$bf_low[[i]] <- rmbayes(nvec = paramdf$x[[i]], alpha = alpha, beta = beta, lg = TRUE, nburn = 50000, niter = 100000)

  alpha <- rep(2, ngam)
  beta <- hwep:::beta_from_alpha(alpha = alpha)
  paramdf$bf_high[[i]] <- rmbayes(nvec = paramdf$x[[i]], alpha = alpha, beta = beta, lg = TRUE)

  alpha <- seq_len(ngam)
  alpha <- alpha / sum(alpha) * ngam
  beta <- hwep:::beta_from_alpha(alpha = alpha)
  paramdf$bf_weird[[i]] <- rmbayes(nvec = paramdf$x[[i]], alpha = alpha, beta = beta, lg = TRUE)

  paramdf$bf_allo[[i]] <- rmbayes(nvec = paramdf$x[[i]], type = "allo")
}
saveRDS(object = paramdf, file =  "./output/large_samp/ldf.RDS")
