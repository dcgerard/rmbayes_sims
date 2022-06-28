## bash arguments ----
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  nc <- 1
} else {
  eval(parse(text = args[[1]]))
}
cat(nc, "\n")

## for analysis ----
library(hwep)
library(tidyr)
library(readr)
library(bench)

## for parallel processing ----
library(foreach)
library(future)
library(doFuture)
library(rngtools)
library(doRNG)

## set up simulation parameters ----
nrep <- 100
paramdf <- expand_grid(seed = seq_len(nrep),
                       n = c(10, 100, 1000),
                       ploidy = c(4, 6, 8),
                       condition = c("null", "alt"))
paramdf$x <- vector(mode = "list", length = nrow(paramdf))

# using posterior mean
paramdf$bf_mean <- rep(NA_real_, length.out = nrow(paramdf))

# using posterior mode
paramdf$bf_mode <- rep(NA_real_, length.out = nrow(paramdf))

# using posterior mean
paramdf$p_mean <- rep(NA_real_, length.out = nrow(paramdf))

# using posterior mode
paramdf$p_mode <- rep(NA_real_, length.out = nrow(paramdf))

# genotype likelihood approach
paramdf$bfgl <- rep(NA_real_, length.out = nrow(paramdf))

# genotype likelihood approach with stan
paramdf$bfstan <- rep(NA_real_, length.out = nrow(paramdf))

# timing
paramdf$bf_time <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$p_time <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$bfgl_time <- rep(NA_real_, length.out = nrow(paramdf))
paramdf$bfstan_time <- rep(NA_real_, length.out = nrow(paramdf))

## shuffle paramdf for even load ----
paramdf <- paramdf[sample(1:nrow(paramdf)), ]

## Set up workers ----
registerDoFuture()
registerDoRNG()
plan("multisession", workers = nc)

simdf <- foreach(i = seq_len(nrow(paramdf)),
                 .combine = rbind,
                 .export = c("paramdf",
                             "simgl",
                             "rmbayes",
                             "rmbayesgl",
                             "rmlike")) %dopar% {
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

  ## genotype log likelihood and posterior matrices ----
  fout <- simgl(nvec = paramdf$x[[i]],
                rdepth = 10,
                od = 0.01,
                bias = 1,
                seq = 0.01,
                ret = "all")
  gl <- fout$genologlike
  gp <- fout$postmat

  ## two ways to get nvec ----
  nvec_mean <- round(colSums(gp))
  nvec_mode <- table(factor(apply(gp, 1, which.max) - 1, levels = 0:paramdf$ploidy[[i]]))
  attributes(nvec_mode) <- NULL

  ## do tests
  paramdf$bf_time[[i]] <- as.numeric(bench::system_time(
    paramdf$bf_mean[[i]] <- rmbayes(nvec = nvec_mean, lg = TRUE)
  )[[2]])

  paramdf$p_time[[i]] <- as.numeric(bench::system_time(
    paramdf$p_mean[[i]] <- log(rmlike(nvec = nvec_mean, thresh = 0)$p_rm)
  )[[2]])

  paramdf$bf_mode[[i]] <- rmbayes(nvec = nvec_mode, lg = TRUE)

  paramdf$p_mode[[i]] <- log(rmlike(nvec = nvec_mode, thresh = 0)$p_rm)

  paramdf$bfstan_time[[i]] <- as.numeric(bench::system_time(
    paramdf$bfstan[[i]] <- rmbayesgl(gl = gl, lg = TRUE, method = "stan")
  )[[2]])

  paramdf$bfgl_time[[i]] <- as.numeric(bench::system_time(
    paramdf$bfgl[[i]] <- rmbayesgl(gl = gl, lg = TRUE, method = "gibbs", iter = 100000)
  )[[2]])

  paramdf[i, ]
}
plan("sequential")
saveRDS(object = simdf, file =  "./output/gl/gldf.RDS")
