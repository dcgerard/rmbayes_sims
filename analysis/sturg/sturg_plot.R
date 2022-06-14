library(tidyverse)
library(qvalue)
library(xtable)
library(updog)
library(patchwork)
library(ggthemes)
bfdf <- read_csv("./output/sturg/sturg_bfdf.csv")
names(bfdf)[[1]] <- "SNP"

# ggplot(bfdf, aes(x = bf, y = p)) +
#   geom_point() +
#   geom_abline(intercept = 0, slope = 1, lty = 2, col = 2) +
#   theme_bw() ->
#   pl

## Histogram of Bayes factors ----

ggplot(bfdf, aes(x = bf)) +
  geom_histogram(bins = 20, col = "black", fill = "white") +
  theme_bw() +
  xlab("Log Bayes Factor") ->
  pl

ggsave(filename = "./output/sturg/sturg_bfhist.pdf",
       plot = pl,
       height = 2,
       width = 4,
       family = "Times")

# ggplot(bfdf, aes(x = exp(p))) +
#   geom_histogram(bins = 20, col = "black", fill = "white") +
#   theme_bw() +
#   xlab("p-value") ->
#   pl

## Weird SNPs ----

bfdf %>%
  arrange(bf) %>%
  filter(bf < -2) %>%
  select(-p) ->
  sturgtab
colnames(sturgtab) <- c("SNP", paste0("$x_", 0:4, "$"), "$\\log$ BF")

print(xtable(sturgtab, digits = c(0, 0, rep(0, 5), 1),
             caption = "SNPs from the white sturgeon data of Section \\ref{sec:sturg} that have log Bayes factors below -2. The SNPs with the lowest three Bayes factors appear to be anomalous.",
             label = "tab:sturg.snps"),
      include.rownames = FALSE,
      sanitize.colnames.function = function(x) x,
      file = "./output/sturg/sturg_snps.tex")

worst_snps <- sturgtab$SNP[1:3]

## raw data from weird SNPs ----
sturgdat <- readRDS("./output/sturg/sturg_updog.RDS")
sturgsub <- filter_snp(sturgdat, snp %in% worst_snps)

which_one <- sturgsub$inddf$snp == worst_snps[[1]]
refvec <- sturgsub$inddf$ref[which_one]
sizevec <- sturgsub$inddf$size[which_one]

local_mode <- flexdog(refvec = refvec, sizevec = sizevec, ploidy = 4, bias_init = 2.7, update_bias = FALSE)

## likelihood differences
sturgsub$snpdf$llike[[1]]
local_mode$llike

## Plot both fits

plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = local_mode$geno,
          seq = local_mode$seq,
          bias = local_mode$bias,
          use_colorblind = TRUE) +
  ggtitle("(B)") +
  labs(color = "Genotype\nEstimate")->
  p1


plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = sturgsub$inddf$geno[which_one],
          bias = sturgsub$snpdf$bias[[1]],
          seq = sturgsub$snpdf$seq[[1]],
          use_colorblind = TRUE) +
  ggtitle("(A)") +
  guides(color = "none") ->
  p2

pdf(file = "./output/sturg/sturg_twofits.pdf", height = 2.6, width = 6, family = "Times")
p2 + p1
dev.off()


## Histogram of biases
ggplot(sturgdat$snpdf, aes(x = bias)) +
  geom_histogram(bins = 15, fill = "white", color = "black") +
  theme_bw() +
  geom_vline(xintercept = local_mode$bias, lty = 2) +
  xlab("Bias Parameter Estimates") ->
  pl

ggsave(filename = "./output/sturg/sturg_bias_hist.pdf",
       plot = pl,
       height = 2,
       width = 4,
       family = "Times")

##
nnew <- table(factor(local_mode$geno, levels = 0:4))
hwep::rmbayes(nnew)

