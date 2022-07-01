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
  select(-p, -eqpval) ->
  sturgtab
colnames(sturgtab) <- c("SNP", paste0("$x_", 0:4, "$"), "$\\log$ BF")

print(xtable(sturgtab, digits = c(0, 0, rep(0, 5), 1),
             caption = "SNPs from the white sturgeon data of Section \\ref{sec:sturg} that have log Bayes factors below -2. The SNPs with the lowest three Bayes factors appear to be anomalous.",
             label = "tab:sturg.snps"),
      include.rownames = FALSE,
      sanitize.colnames.function = function(x) x,
      file = "./output/sturg/sturg_snps.tex")

worst_snps <- sturgtab$SNP[1:6]

## raw data from weird SNPs ----
sturgdat <- readRDS("./output/sturg/sturg_updog.RDS")
sturgsub <- filter_snp(sturgdat, snp %in% worst_snps)


## First SNP -------------------------------------------------------------
which_one <- sturgsub$inddf$snp == worst_snps[[1]]
refvec <- sturgsub$inddf$ref[which_one]
sizevec <- sturgsub$inddf$size[which_one]

local_mode1 <- flexdog(refvec = refvec,
                       sizevec = sizevec,
                       ploidy = 4,
                       bias_init = 2.7)
global_mode1 <- flexdog(refvec = refvec,
                       sizevec = sizevec,
                       ploidy = 4)

## likelihood differences
global_mode1$llike
local_mode1$llike

## Plot both fits

plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = local_mode1$geno,
          seq = local_mode1$seq,
          bias = local_mode1$bias,
          use_colorblind = TRUE) +
  ggtitle(paste0("(B) LL = ", round(local_mode1$llike))) +
  labs(color = "Genotype\nEstimate")->
  p1


plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = global_mode1$geno,
          seq = global_mode1$seq,
          bias = global_mode1$bias,
          use_colorblind = TRUE) +
  ggtitle(paste0("(A) LL = ", round(global_mode1$llike))) +
  guides(color = "none") ->
  p2

pdf(file = "./output/sturg/sturg_twofits.pdf", height = 2.6, width = 6, family = "Times")
p2 + p1
dev.off()

## New Bayes factor
nold <- table(factor(global_mode1$geno, levels = 0:4))
hwep::rmbayes(nold)

nnew <- table(factor(local_mode1$geno, levels = 0:4))
hwep::rmbayes(nnew)

## Histogram of biases
ggplot(sturgdat$snpdf, aes(x = bias)) +
  geom_histogram(bins = 15, fill = "white", color = "black") +
  theme_bw() +
  geom_vline(xintercept = local_mode1$bias, lty = 2) +
  xlab("Bias Parameter Estimates") ->
  pl

ggsave(filename = "./output/sturg/sturg_bias_hist.pdf",
       plot = pl,
       height = 2,
       width = 4,
       family = "Times")

## Second SNP -------------------------------------------------------------
which_one <- sturgsub$inddf$snp == worst_snps[[2]]
refvec <- sturgsub$inddf$ref[which_one]
sizevec <- sturgsub$inddf$size[which_one]

local_mode2 <- flexdog(refvec = refvec,
                       sizevec = sizevec,
                       ploidy = 4,
                       bias_init = 2.7)
global_mode2 <- flexdog(refvec = refvec,
                       sizevec = sizevec,
                       ploidy = 4)

## likelihood differences
global_mode2$llike
local_mode2$llike

## Plot both fits

plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = local_mode2$geno,
          seq = local_mode2$seq,
          bias = local_mode2$bias,
          use_colorblind = TRUE) +
  ggtitle(paste0("(B) LL = ", round(local_mode2$llike))) +
  labs(color = "Genotype\nEstimate")->
  p1

plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = global_mode2$geno,
          seq = global_mode2$seq,
          bias = global_mode2$bias,
          use_colorblind = TRUE) +
  ggtitle(paste0("(A) LL = ", round(global_mode2$llike))) +
  guides(color = "none") ->
  p2

pdf(file = "./output/sturg/sturg_twofits_2.pdf", height = 2.6, width = 6, family = "Times")
p2 + p1
dev.off()

## New bayes factor
nold <- table(factor(global_mode2$geno, levels = 0:4))
hwep::rmbayes(nold)

nnew <- table(factor(local_mode2$geno, levels = 0:4))
hwep::rmbayes(nnew)

## Third SNP -------------------------------------------------------------
which_one <- sturgsub$inddf$snp == worst_snps[[3]]
refvec <- sturgsub$inddf$ref[which_one]
sizevec <- sturgsub$inddf$size[which_one]

local_mode3 <- flexdog(refvec = refvec,
                       sizevec = sizevec,
                       ploidy = 4,
                       bias_init = 2.7)
global_mode3 <- flexdog(refvec = refvec,
                       sizevec = sizevec,
                       ploidy = 4)

## likelihood differences
global_mode3$llike
local_mode3$llike

## Plot both fits

plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = local_mode3$geno,
          seq = local_mode3$seq,
          bias = local_mode3$bias,
          use_colorblind = TRUE) +
  ggtitle(paste0("(B) LL = ", round(local_mode3$llike))) +
  labs(color = "Genotype\nEstimate")->
  p1

plot_geno(refvec = refvec,
          sizevec = sizevec,
          ploidy = 4,
          geno = global_mode3$geno,
          seq = global_mode3$seq,
          bias = global_mode3$bias,
          use_colorblind = TRUE) +
  ggtitle(paste0("(A) LL = ", round(global_mode3$llike))) +
  guides(color = "none") ->
  p2

pdf(file = "./output/sturg/sturg_twofits_3.pdf", height = 2.6, width = 6, family = "Times")
p2 + p1
dev.off()

## New bayes factor
nold <- table(factor(global_mode3$geno, levels = 0:4))
hwep::rmbayes(nold)

nnew <- table(factor(local_mode3$geno, levels = 0:4))
hwep::rmbayes(nnew)

#################################################
## Likelihood stuf ----
#################################################

ggplot(bfdf, aes(x = bf, y = p)) +
  geom_point() +
  xlab("Log Bayes Factor") +
  ylab("Log p-value") +
  theme_bw() +
  geom_smooth(method = "lm", se = FALSE, formula = y ~ x) ->
  pl

ggsave(filename = "./output/sturg/sturg_bf_vs_p.pdf",
       plot = pl,
       height = 3,
       width = 4,
       family = "Times")

bfdf %>%
  mutate(p = exp(p)) %>%
  ggplot(aes(x = p)) +
  geom_histogram(bins = 15, color = "black", fill = "white") +
  theme_bw() +
  xlab("p-value") ->
  pl

ggsave(filename = "./output/sturg/sturg_p_hist.pdf",
       plot = pl,
       height = 3,
       width = 4,
       family = "Times")

qout <- qvalue(exp(bfdf$p))
head(sort(qout$qvalues))

