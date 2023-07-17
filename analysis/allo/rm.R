library(gsignal)
library(tidyverse)
library(ggthemes)

#' Produces next generation of subgenom genotype frequencies under the
#' assumption of random mating.
#'
#' @param gf Subgenome genotype frequencies. A 3 x 3 matrix where element (i,j)
#'     is hte frequency of genotype i-1 in the first subgenome and genotype
#'     j-1 in the second subgenom.
#'
#' @author David Gerard
nextgen <- function(gf) {
  ## make sure valid input
  TOL <- sqrt(.Machine$double.eps)
  stopifnot(abs(sum(gf) - 1) < TOL)

  pf = matrix(
    c(
      gf[1, 1] + 0.5 * gf[1, 2] + 0.5 * gf[2, 1] + 0.25 * gf[2, 2],
      0.5 * gf[1, 2] + gf[1, 3] + 0.25 * gf[2, 2] + 0.5 * gf[2, 3],
      0.5 * gf[2, 1] + 0.25 * gf[2, 2] + gf[3, 1] + 0.5 * gf[3, 2],
      0.25 * gf[2, 2] + 0.5 * gf[2, 3] + 0.5 * gf[3, 2] + gf[3, 3]
    ),
    ncol = 2,
    nrow = 2,
    byrow = TRUE)

  return(gsignal::conv2(pf, pf))
}

#' Get overall genotype frequencies from genotype frequencies of subgenomes
#'
#' @inheritParams nextgen
genofreq <- function(gf) {
  tapply(gf, row(gf) + col(gf) - 2, sum)
}

gf <- structure(c(0.1, 0, 0, 0.2, 0.3, 0.1, 0, 0, 0.3), dim = c(3L, 3L))

## Starting overall genotype frequencies
gmat <- genofreq(gf)

## Starting subgenome genotype frequencies
g1 <- rowSums(gf)
g2 <- colSums(gf)

## Starting subgenome allele frequencies
r1 <- sum(0:2 * g1) / 2
r2 <- sum(0:2 * g2) / 2

## Predicted equilibrium frequencies
gpred <- convolve(dbinom(0:2, 2, r1), rev(dbinom(0:2, 2, r2)), type = "open")

## one generation is enough for subgenome HWP
rowSums(nextgen(gf))
dbinom(0:2, 2, r1)

colSums(nextgen(gf))
dbinom(0:2, 2, r2)

## many rounds of random mating
for (i in 1:10) {
  gf <- nextgen(gf)
  gmat <- rbind(gmat, genofreq(gf))
}

## New genotype frequencies same as equilibrium genotype frequencies
genofreq(gf)
gpred

## Plot results
gmat %>%
  as_tibble() %>%
  mutate(Generation = 1:n() - 1) %>%
  pivot_longer(cols = -Generation, names_to = "Genotype", values_to = "GF") %>%
  mutate(Genotype = parse_factor(Genotype)) %>%
  ggplot(aes(x = Generation, y = GF, color = Genotype)) +
  geom_line() +
  theme_bw() +
  scale_color_colorblind() +
  ylab("Genotype Frequencies") +
  scale_x_continuous(breaks = 0:10) ->
  pl

ggsave(filename = "./output/allo/gf_allo.pdf",
       plot = pl,
       height = 2,
       width = 4,
       family = "Times")
