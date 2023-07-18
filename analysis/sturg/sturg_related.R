library(AGHmatrix)
library(updog)
library(stringr)

uout <- readRDS("./output/sturg/sturg_updog.RDS")
genomat <- t(format_multidog(x = uout, varname = "geno"))

gmat <- Gmatrix(SNPmatrix = genomat, ploidy = 4)

colnames(gmat) |>
  str_remove("^Sample_") |>
  str_remove("_.*$") ->
  namevec
colnames(gmat) <- namevec
rownames(gmat) <- namevec

pdf(file = "./output/sturg/sturg_related.pdf", height = 4, width = 4, family = "Times")
corrplot::corrplot(gmat,
                   type = "upper",
                   method = "color",
                   is.corr = FALSE,
                   order = "AOE")
dev.off()
