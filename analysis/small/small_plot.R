library(tidyverse)
library(hwep)

bfp <- read_csv("./output/small_samp/bfp.csv")

qplot(dfbf$bf)
qplot(dfbf$p)

qplot(dfbf$bf, log(dfbf$p))

xmat[which.min(dfbf$bf), ]
xmat[which.max(dfbf$bf), ]

head(dfbf[order(dfbf$bf), ])
head(dfbf[rev(order(dfbf$bf)), ])

rmlike(nvec = c(2, 3, 7, 4, 4), thresh = 0)$p_rm
rmbayes(nvec = c(2, 3, 7, 4, 4))
rmlike(nvec = c(6, 0, 0, 14, 0), thresh = 0)$p_rm
exp(rmbayes(nvec = c(6, 0, 0, 14, 0)))
