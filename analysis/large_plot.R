library(tidyverse)

ldf <- readRDS("./output/large_samp/ldf.RDS")

ldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  ggplot(aes(x = n, y = bf)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("log Bayes factor") ->
  pl

ggsave(filename = "./output/large_samp/bf_large.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")

ldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  ggplot(aes(x = n, y = p)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("log p-value")

