library(tidyverse)
library(updog)
bfdf <- read_csv("./output/shir/shir_bfdf.csv")
colnames(bfdf)[[1]] <- "SNP"
bf_gl <- readRDS("./output/shir/bf_gl.RDS")
bfdf$bfgl <- bf_gl

ggplot(bfdf, aes(x = bf)) +
  geom_histogram(bins = 20, col = "black", fill = "white") +
  theme_bw() +
  xlab("Log Bayes Factor")

ggplot(bfdf, aes(x = exp(p))) +
  geom_histogram(bins = 20, col = "black", fill = "white") +
  theme_bw() +
  xlab("p-value")

ggplot(bfdf, aes(x = bf, y = p)) +
  geom_point() +
  theme_bw() +
  xlab("Log Bayes Factor") +
  ylab("Log p-value")

ggplot(bfdf, aes(x = bf, y = bfgl)) +
  geom_point() +
  theme_bw() +
  xlab("Bayes Factor (known genotypes)") +
  ylab("Bayes Factor (genotype likelihoods)") +
  geom_abline(lty = 2, col = 2)

## Explore problem SNPs
shirdat <- readRDS("./output/shir/shir_updog.RDS")

bfdf %>%
  arrange(bfgl) %>%
  slice(2) %>%
  .$SNP ->
  worst_snp

plot(filter_snp(shirdat, snp == worst_snp))[[1]]

glmat <- format_multidog(filter_snp(shirdat, snp == worst_snp), varname = paste0("logL_", 0:6))
gpmat <- format_multidog(filter_snp(shirdat, snp == worst_snp), varname = paste0("Pr_", 0:6))

gl2 <- glmat
which_row_na <- apply(is.na(gl2), 1, any)
gl2 <- gl2[!which_row_na, , drop = FALSE]
hwep::rmbayesgl(gl2)

psnull <- hwep:::gibbs_gl(gl = gl2, alpha = rep(1, 4), more = TRUE, lg = TRUE)
psalt <- hwep:::gibbs_gl_alt(gl = gl2, beta = rep(1, 7), more = TRUE, lg = TRUE)
psnull$mx
psalt$mx

bfdf %>%
  filter(SNP == worst_snp) %>%
  select(starts_with("X")) %>%
  as.matrix() %>%
  c() ->
  nvec_worst

hwep::rmbayes(nvec_worst)

