library(tidyverse)
library(ggthemes)

ldf <- readRDS("./output/large_samp/ldf.RDS")

## Bayes factor plot
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

## p-value plot
ldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  ggplot(aes(x = n, y = p)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("log p-value") ->
  pl

## Time plot
ldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  gather(key = "Method", value = "Time", bf_time, p_time) %>%
  mutate(Method = recode(Method, "bf_time" = "Bayes", "p_time" = "LRT")) %>%
  ggplot(aes(x = n, y = Time, fill = Method)) +
  facet_grid(condition ~ ploidy) +
  geom_boxplot(outlier.size = 0.3) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  ylab("Time (seconds)") +
  scale_y_log10() +
  scale_fill_colorblind() ->
  pl

ggsave(filename = "./output/large_samp/time_large.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")
