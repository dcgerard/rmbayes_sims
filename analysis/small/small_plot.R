library(tidyverse)
library(hexbin)
library(hwep)
library(xtable)
library(broom)

bfp <- read_csv("./output/small_samp/bfp.csv")

bfp %>%
  mutate(ploidy = parse_factor(paste0("K = ", ploidy)),
         n = parse_factor(paste0("n = ", n))) ->
  bfp

## Distribution and extremes -----

bfp %>%
  ggplot(aes(x = bf)) +
  facet_grid(n ~ ploidy) +
  geom_histogram(aes(y = ..density..), bins = 20, color = "black", fill = "white") +
  theme_bw() +
  xlab("Log Bayes Factor") +
  theme(strip.background = element_rect(fill = "white")) ->
  pl

ggsave(filename = "./output/small_samp/small_bf_hist.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")

bfp %>%
  group_by(ploidy, n) %>%
  arrange(desc(bf)) %>%
  slice(1, n()) %>%
  mutate(order = c("first", "last")) %>%
  relocate(ploidy, n, bf, p, order, everything()) %>%
  ungroup() %>%
  arrange(order, ploidy, n) %>%
  select(-order) %>%
  mutate(ploidy = str_remove(ploidy, "K = "),
         n = str_remove(n, "n = ")) %>%
  as.data.frame() ->
  extremedf

extremedf[is.na(extremedf)] <- "-"
colnames(extremedf) <- c("Ploidy", "$n$", "$\\log$ BF", "$\\log$ $p$-value", paste0("$x_", 0:8, "$"))

print(xtable(extremedf,
             caption = "Small sample datasets with highest and lowest Bayes factors by ploidy and sample size. Very large Bayes factors tend to be unimodal, whereas very small Bayes factors tend to have a couple prominant modes.",
             label = "tab:extreme.bf",
             digits = c(0, 0, 0, 2, 2, rep(0, 9))),
      include.rownames = FALSE,
      sanitize.colnames.function = function(x) x,
      file = "./output/small_samp/tab_extreme_bf.tex")

## Compare to p-values ----

bfp %>%
  ggplot(aes(x = bf, y = p)) +
  geom_hex() +
  facet_grid(n ~ ploidy) +
  theme_bw() +
  xlab("Log Bayes Factor") +
  ylab("Log p-value") +
  theme(strip.background = element_rect(fill = "white")) +
  scale_fill_gradient(trans = "log", breaks = c(1, 5, 50, 500), low = "gray10", high = "gray90") ->
  pl

ggsave(filename = "./output/small_samp/small_bfp_hex.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")

## largest difference by residual

bfp %>%
  group_by(n, ploidy) %>%
  nest() %>%
  mutate(lm = map(data, ~lm(bf ~ p, data = .))) %>%
  mutate(resid = map(lm, ~data.frame(res = resid(.)))) %>%
  unnest(cols = c("data", "resid")) %>%
  select(-lm) %>%
  arrange(res) %>%
  relocate(ploidy, n, bf, p, res, everything()) %>%
  slice(1, n()) %>%
  mutate(type = c("first", "last")) %>%
  ungroup() %>%
  arrange(type, ploidy, n) %>%
  select(-type) %>%
  mutate(ploidy = str_remove(ploidy, "K = "),
         n = str_remove(n, "n = ")) %>%
  as.data.frame() ->
  difftab

difftab[is.na(difftab)] <- "-"
colnames(difftab) <- c("Ploidy", "$n$", "$\\log$ BF", "$\\log$ $p$-value", "Residual", paste0("$x_", 0:8, "$"))

print(xtable(difftab,
             caption = "Values of $\\bs{x}$ that provide the most different results between the Bayes test and the likelihood ratio test for different ploidies and sample sizes. The residual column is from a regresion of the log Bayese factor on the log p-value, with negative residual values indicating the Bayes factor provides more evidence against the null than expected, and positive residual values indicating the Bayes factor provides less evidence againts the null than expected.",
             label = "tab:diff.p.bf",
             digits = c(0, 0, 0, 2, 2, 2, rep(0, 9))),
      include.rownames = FALSE,
      sanitize.colnames.function = function(x) x,
      file = "./output/small_samp/tab_diff_p_bf.tex")

# Look at distribution of bayes factors when p = 0.05

bfp %>%
  mutate(pval = exp(p)) %>%
  filter(pval > 0.047, pval < 0.053) %>%
  group_by(n, ploidy) %>%
  arrange(bf) %>%
  slice(1, n()) %>%
  select(-p) %>%
  relocate(ploidy, n, bf, pval, everything()) %>%
  mutate(type = c("first", "last")) %>%
  ungroup() %>%
  arrange(ploidy, n, type) %>%
  select(-type) %>%
  mutate(ploidy = str_remove(ploidy, "K = "),
         n = str_remove(n, "n = ")) %>%
  as.data.frame() ->
  z5tab

z5tab[is.na(z5tab)] <- "-"
colnames(z5tab) <- c("Ploidy", "$n$", "$\\log$ BF", "$p$-value", paste0("$x_", 0:8, "$"))

print(xtable(z5tab,
             caption = "Highest and lowest Bayes factors when the $p$-value is near 0.05 for each ploidy and sample size.",
             label = "tab:bf.near.p05",
             digits = c(0, 0, 0, 2, 3, rep(0, 9))),
      include.rownames = FALSE,
      sanitize.colnames.function = function(x) x,
      file = "./output/small_samp/tab_bf_near_p05.tex")

x1 <- c(0, 0, 1, 7, 1, 0, 0, 0, 1)
rmbayes(nvec = x1)
rmlike(nvec = x1, thresh = 0)$p_rm

x2 <- c(4, 2, 3, 0, 0, 0, 0, 1, 0)
rmbayes(nvec = x2)
rmlike(nvec = x2, thresh = 0)$p_rm

priorlist <- hwep:::conc_default(ploidy = 8)
gibbs_known(x = x1, alpha = priorlist$alpha, lg = TRUE)
gibbs_known(x = x2, alpha = priorlist$alpha, lg = TRUE)
hwep:::ddirmult(x = x1, alpha = priorlist$beta, lg = TRUE)
hwep:::ddirmult(x = x2, alpha = priorlist$beta, lg = TRUE)

hwep:::ddirmult(x = x1, alpha = rep(1, 9), lg = TRUE)
hwep:::ddirmult(x = x2, alpha = rep(1, 9), lg = TRUE)

# gk <- gibbs_known(x = x2, alpha = rep(1, 5), more = TRUE, lg = TRUE)
# colnames(gk$p) <- paste0("p", 0:4)
# gk$p %>%
#   as_tibble() %>%
#   gather(key = "variable", value = "value") %>%
#   group_by(variable) %>%
#   mutate(index = row_number()) %>%
#   ggplot(aes(x = value)) +
#   facet_wrap(. ~ variable) +
#   geom_histogram()
# pmode <- gk$p[which.max(gk$post), ]
# pmle <- rmlike(nvec = x2, thresh = 0)$p

## See if monotonicity is important ----

#' Checks if x is monotone
#'
#' @param x a sequence
#'
#' @author David Gerard
#'
#' @examples
#' is_monotone(c(1, 2, 3, 3, 2, 1))
#' is_monotone(c(1, 2, 3, 1, 2, 1))
#' is_monotone(c(3, 2, 1))
#' is_monotone(c(1, 2, 3))
#' is_monotone(c(1, 1, 1))
#' is_monotone(c(NA, NA, 1, 3, 4, 0))
#'
is_monotone <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) <= 1) {
    return(TRUE)
  }
  pastmode <- FALSE
  cx <- x[[1]]
  for (i in 2:length(x)) {
    if (!pastmode) {
      if (x[[i]] < x[[i - 1]]) {
        pastmode <- TRUE
      }
    } else {
      if (x[[i]] > x[[i - 1]]) {
        return(FALSE)
      }
    }
  }
  return(TRUE)
}

bfp %>%
  select(starts_with("D")) %>%
  as.matrix() %>%
  apply(MARGIN = 1, FUN = is_monotone) ->
  monovec

bfp$mono <- monovec

bfp %>%
  ggplot(aes(x = mono, y = bf)) +
  geom_boxplot() +
  facet_grid(n ~ ploidy) +
  theme_bw() +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Monotone") +
  ylab("Log Bayes Factor") ->
  pl

ggsave(filename = "./output/small_samp/small_monotone_box.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")

pseq <- expand.grid(p0 = ppoints(100), p1 = ppoints(100))
pseq$p2 <- 1 - pseq$p0 - pseq$p1
pseq$mono <- apply(as.matrix(pseq), 1, is_monotone)
