#####################
## Plot results of gl simulations
#####################

library(tidyverse)
library(ggthemes)

gldf <- readRDS("./output/gl/gldf.RDS")

## show consistency ----
gldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  select(n, ploidy, condition, bf_mean, bfstan) %>%
  gather(bf_mean, bfstan, key = "Method", value = "bf") %>%
  mutate(simv = case_when(condition == "null" & Method == "bf_mean" ~ "Null, Known",
                          condition == "null" & Method == "bfstan" ~ "Null, GL",
                          condition == "alt" & Method == "bf_mean" ~ "Alt, Known",
                          condition == "alt" & Method == "bfstan" ~ "Alt, GL")) %>%
  ggplot(aes(x = n, y = bf)) +
  facet_grid(simv ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("log Bayes factor") +
  scale_color_colorblind() ->
  pl

ggsave(filename = "./output/gl/gl_consist.pdf",
       plot = pl,
       height = 7,
       width = 6,
       family = "Times")

## Show Gibbs sampler falls short ----

gldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  select(n, ploidy, condition, bfgl) %>%
  ggplot(aes(x = n, y = bfgl)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("log Bayes factor") +
  scale_color_colorblind() ->
  pl

ggsave("./output/gl/gl_box_gibbs.pdf",
       plot = pl,
       height = 4,
       width = 6,
       family = "Times")

## Compare Gibbs to Stan ----

gldf %>%
  filter(condition == "null") %>%
  mutate(n = as.factor(paste0("n = ", n)),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  ggplot(aes(x = bfgl, y = bfstan)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  facet_wrap(n ~ ploidy, scales = "free") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white", color = "black")) +
  xlab("BF from Gibbs Sampler") +
  ylab("BF from Stan") ->
  pl

ggsave(filename = "./output/gl/bf_compare_null.pdf",
       plot = pl,
       height = 6,
       width = 6,
       family = "Times")

gldf %>%
  filter(condition == "alt") %>%
  mutate(n = as.factor(paste0("n = ", n)),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  ggplot(aes(x = bfgl, y = bfstan)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  facet_wrap(n ~ ploidy, scales = "free") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white", color = "black")) +
  xlab("BF from Gibbs Sampler") +
  ylab("BF from Stan") ->
  pl

ggsave(filename = "./output/gl/bf_compare_alt.pdf",
       plot = pl,
       height = 6,
       width = 6,
       family = "Times")

## Timing ----

gldf %>%
  mutate(n = factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  select(n, ploidy, Gibbs = bfgl_time, Stan = bfstan_time) %>%
  gather(-n, -ploidy, key = "Method", value = "Time") %>%
  ggplot(aes(x = n, y = Time, color = Method)) +
  facet_wrap(. ~ ploidy) +
  geom_boxplot() +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Sample Size") +
  ylab("Time (seconds)") +
  scale_y_log10() ->
  pl

ggsave(filename = "./output/gl/gl_time.pdf",
       plot = pl,
       height = 2,
       width = 6,
       family = "Times")