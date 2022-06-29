library(tidyverse)
library(updog)
library(hwep)
library(patchwork)
library(ggpubr)
library(xtable)
bfdf <- read_csv("./output/shir/shir_bfdf.csv") ## known fit
colnames(bfdf)[[1]] <- "SNP"
bf_gl <- readRDS("./output/shir/bf_gl.RDS") ## GL fit
bfdf$bfgl <- bf_gl
shirdat <- readRDS("./output/shir/shir_updog.RDS") ## raw data

## Plot Bayes factors ----

ggplot(bfdf, aes(x = bfgl, y = bf)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  theme_bw() +
  xlab("Log Bayes Factor\nUsing Genotype Likelihoods") +
  ylab("Log Bayes Factor\nUsing Known Genotypes") ->
  pl

ggsave(filename = "./output/shir/shir_bf_scatter.pdf",
       plot = pl,
       height = 2.5,
       width = 3.5,
       family = "Times")

ggplot(bfdf, aes(x = bfgl)) +
  geom_histogram(bins = 20, col = "black", fill = "white") +
  theme_bw() +
  xlab("Log Bayes Factor") ->
  pl

ggsave(filename = "./output/shir/shir_bf_hist.pdf",
       plot = pl,
       height = 2,
       width = 3,
       family = "Times")

## Plot problem loci fits ----

bfdf %>%
  arrange(bfgl) %>%
  filter(bfgl < -5) %>%
  select(SNP, bfgl) ->
  baddf

subdat <- filter_snp(shirdat, snp %in% baddf$SNP)
subdat$snpdf <- subdat$snpdf[match(baddf$SNP, subdat$snpdf$snp), ]

pl_list <- plot(subdat, indices = 1:nrow(subdat$snpdf))
pl_list[[1]] <- pl_list[[1]] + guides(alpha = "none",
                                      color = guide_legend(nrow = 3, title = "Genotype Estimate"))
pl_list[[nrow(subdat$snpdf) + 1]] <- ggpubr::as_ggplot(ggpubr::get_legend(pl_list[[1]]))
for (i in 1:(nrow(subdat$snpdf))) {
  pl_list[[i]] <- pl_list[[i]] +
    guides(color = "none", alpha = "none") +
    theme(title = element_text(size = 10))
}

pdf(file = "./output/shir/shir_up_fits.pdf", height = 7, width = 6, family = "Times")
wrap_plots(pl_list, nrow = 3)
dev.off()

## Create a table of problem loci ----

probdat <- updog::get_q_array(ploidy = 6)
probmat <- rbind(
  probdat[1, 1, ],
  probdat[2, 2, ],
  probdat[3, 3, ],
  probdat[4, 4, ],
  probdat[5, 5, ],
  probdat[6, 6, ],
  probdat[7, 7, ]
  )

obsmat <- round(apply(format_multidog(x = subdat, varname = paste0("Pr_", 0:6)), c(1, 3), sum, na.rm = TRUE))
expmat <- round(probmat[subdat$snpdf$pgeno + 1, ] * rowSums(obsmat))

bothmat <- paste(obsmat, expmat, sep = "/")
dim(bothmat) <- dim(obsmat)
rownames(bothmat) <- rownames(obsmat)
colnames(bothmat) <- 0:6
bothdf <- as_tibble(bothmat, rownames = "SNP")

subdat$snpdf %>%
  select(SNP = snp, `Pr(Mis)` = prop_mis, Parent = pgeno) %>%
  left_join(baddf, by = "SNP") %>%
  relocate(bfgl, .before = Parent) %>%
  rename(`Log BF` = bfgl) %>%
  left_join(bothdf, by = "SNP") %>%
  xtable(label = "tab:shir.bad.snp", digits = c(0, 0, 2, 2, 0, rep(0, 7)),
         caption = "Five SNPs from the sweet potato data of Section
  \\ref{sec:shir} with log Bayes factors less than -5. The estimated
  proportion of individuals mis-genotypes and the estimated parental
  gentoype were provided by \\texttt{updog}
  \\citep{gerard2018genotyping, gerard2019priors}, and the log Bayes
  factor was calculated using the method of Section \\ref{sec:gl}. The
  right half of the table contains the observed/expected counts for
  the genotypes 0 through 6. The expected counts were calculated
  assuming the parental genotype is correct using a convolution of
  hypergeometric distributions \\citet{serang2012efficient}.") %>%
  print(include.rownames = FALSE,
        file = "./output/shir/shir_bad_tab.tex")
