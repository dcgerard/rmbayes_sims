library(tidyverse)
library(hexbin)
library(hwep)

bfp <- read_csv("./output/small_samp/bfp.csv")

bfp %>%
  ggplot(aes(x = bf)) +
  facet_grid(ploidy ~ n) +
  geom_histogram(aes(y = ..density..), bins = 20, color = "black", fill = "white") +
  theme_bw() +
  xlab("Log Bayes Factor") +
  theme(strip.background = element_rect(fill = "white"))

bfp %>%
  filter(ploidy == 4, n == 5) %>%
  arrange(desc(bf))

bfp %>%
  filter(ploidy == 4, n == 5) %>%
  arrange(bf)

bfp %>%
  ggplot(aes(x = bf, y = p)) +
  geom_hex() +
  facet_grid(ploidy ~ n) +
  theme_bw() +
  xlab("Log Bayes Factor") +
  ylab("Log p-value") +
  theme(strip.background = element_rect(fill = "white"))


#####
## See if monotonicity is important
#####

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
  filter(ploidy == 8, n == 10) %>%
  select(bf, mono) %>%
  ggplot(aes(x = mono, y = bf)) +
  geom_boxplot()

