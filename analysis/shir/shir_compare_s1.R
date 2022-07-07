library(tidyverse)
library(xtable)
library(updog)
library(patchwork)
library(hwep)

glvec <- readRDS("./output/shir/bf_gl.RDS")
s1vec <- readRDS("./output/shir/bf_s1.RDS")
shirdat <- readRDS("./output/shir/shir_updog.RDS")

table(GL = glvec < 0, S1 = s1vec < 0)

tibble(gl = glvec, s1 = s1vec) %>%
  filter(gl > 0, s1 > 0) %>%
  ggplot(aes(x = gl, y = s1)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  theme_bw() +
  xlab("Random Mating Log Bayes Factor") +
  ylab("S1 Log Bayes Factor") ->
  pl

ggsave(filename = "./output/shir/s1_compare/s1_g0.pdf",
       plot = pl,
       height = 2,
       width = 3,
       family = "Times")

tibble(gl = glvec, s1 = s1vec, snp = shirdat$snpdf$snp) %>%
  mutate(diff = gl - s1) %>%
  filter(gl > 0, s1 < 0) %>%
  arrange(desc(diff)) %>%
  select(-diff) %>%
  slice(1:8 * 5) ->
  badsnp

## Genotype plots of bad snps
filter_snp(shirdat, snp %in% badsnp$snp) %>%
  plot(indices = 1:8) ->
  pl_list
pl_list[[1]] <- pl_list[[1]] + guides(alpha = "none",
                                      color = guide_legend(nrow = 3, title = "Genotype Estimate"))
pl_list[[length(pl_list) + 1]] <- ggpubr::as_ggplot(ggpubr::get_legend(pl_list[[1]]))
for (i in seq_along(pl_list)) {
  pl_list[[i]] <- pl_list[[i]] +
    guides(color = "none", alpha = "none") +
    theme(title = element_text(size = 7))
}

pdf(file = "./output/shir/s1_compare/s1_snps.pdf",
    height = 7,
    width = 6,
    family = "Times")
wrap_plots(pl_list, nrow = 3)
dev.off()

## Subset of data
subdat <- filter_snp(shirdat, snp %in% badsnp$snp)
qarray <- get_q_array(ploidy = 6)
badsnp$s1_new <- NA_real_
beta <- hwep:::conc_default(ploidy = 6)$beta
for (i in seq_along(badsnp$snp)) {
  cat(i, "\n")
  cdat <- filter_snp(subdat, snp == badsnp$snp[[i]])
  pgeno <- cdat$snpdf$pgeno
  possible_genos <- which(qarray[pgeno + 1, pgeno + 1, ] > 10^-6) - 1
  cdat$inddf %>%
    filter(geno %in% possible_genos) ->
    cdat$inddf

  glmat <- format_multidog(x = cdat, varname = paste0("logL_", 0:6))

  trash <- capture.output(
    badsnp$s1_new[[i]] <- menbayesgl(gl = glmat, method = "s1", beta = beta)
  )
}

## S1 method is very sensitive to a couple individuals not matching
subdat$snpdf %>%
  select(snp, pgeno) ->
  snpdf
subdat$inddf %>%
  mutate(geno = factor(geno, levels = 0:6)) %>%
  group_by(snp) %>%
  count(geno) %>%
  spread(key = geno, value = n, fill = 0) %>%
  select(-`<NA>`) %>%
  left_join(snpdf) %>%
  left_join(badsnp) %>%
  mutate(`3` = 0) %>%
  relocate(`3`, .before = `4`) %>%
  rename(SNP = snp,
         `Parent Genotype` = pgeno,
         RM = gl,
         S1 = s1,
         `S1 New` = s1_new,
         `$\\hat{x}_0$` = `0`,
         `$\\hat{x}_1$` = `1`,
         `$\\hat{x}_2$` = `2`,
         `$\\hat{x}_3$` = `3`,
         `$\\hat{x}_4$` = `4`,
         `$\\hat{x}_5$` = `5`,
         `$\\hat{x}_6$` = `6`) %>%
  xtable(digits = c(rep(0, 10), rep(1, 3))) %>%
  print(file = "./output/shir/s1_compare/s1_badsnp.tex",
        include.rownames = FALSE,
        sanitize.colnames.function = function(x) x)
