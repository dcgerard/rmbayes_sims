library(tidyverse)
library(hexbin)
library(hwep)
library(xtable)

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
  select(-order) ->
  extremedf

print(xtable(extremedf), include.rownames = FALSE)

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
