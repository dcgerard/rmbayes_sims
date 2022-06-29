#######################
## Q-value analysis for sturgeon p-values
#######################

library(tidyverse)
library(qvalue)
library(hwep)
bfdf <- read_csv("./output/sturg/sturg_bfdf.csv")
names(bfdf)[[1]] <- "SNP"

## Histogram of equilibrium p-values
pl <- qqpvalue(pvals = bfdf$eqpval, method = "ggplot2", return_plot = TRUE)
ggsave(filename = "./output/sturg/equi_pval_qq.pdf",
       plot = pl,
       height = 2,
       width = 3,
       family = "Times")

qout <- qvalue(bfdf$eqpval)
1 - qout$pi0

sum(qout$qvalues < 0.05, na.rm = TRUE)
