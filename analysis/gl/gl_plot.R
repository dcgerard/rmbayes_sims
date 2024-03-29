#####################
## Plot results of gl simulations
#####################

library(tidyverse)
library(ggthemes)
library(hwep)

gldf <- readRDS("./output/gl/gldf.RDS")

## show consistency ----
gldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  filter(est, priorclass == "flex") %>%
  select(n, ploidy, condition, bf_mode, bf_mean, bfstan) %>%
  gather(bf_mode, bf_mean, bfstan, key = "Method", value = "bf") %>%
  mutate(simv = case_when(condition == "null" & Method == "bf_mean" ~ "Null, Mean",
                          condition == "null" & Method == "bf_mode" ~ "Null, Mode",
                          condition == "null" & Method == "bfstan" ~ "Null, GL",
                          condition == "alt" & Method == "bf_mean" ~ "Alt, Mean",
                          condition == "alt" & Method == "bf_mode" ~ "Alt, Mode",
                          condition == "alt" & Method == "bfstan" ~ "Alt, GL")) %>%
  ggplot(aes(x = n, y = bf)) +
  facet_grid(simv ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("Log Bayes Factor") +
  xlab("Sample Size") +
  scale_color_colorblind() ->
  pl

ggsave(filename = "./output/gl/gl_consist.pdf",
       plot = pl,
       height = 7,
       width = 6,
       family = "Times")

## Show Gibbs sampler falls short ----

gldf %>%
  filter(est, priorclass == "flex") %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  mutate(condition = recode(condition,
                            "alt" = "Alt",
                            "null" = "Null")) %>%
  select(n, ploidy, condition, bfgl) %>%
  ggplot(aes(x = n, y = bfgl)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("Log Bayes Factor") +
  xlab("Sample Size") +
  scale_color_colorblind() ->
  pl

ggsave("./output/gl/gl_box_gibbs.pdf",
       plot = pl,
       height = 4,
       width = 6,
       family = "Times")

## Compare Gibbs to Stan ----

gldf %>%
  filter(est, priorclass == "flex") %>%
  filter(condition == "null") %>%
  mutate(n = as.factor(paste0("n = ", n)),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  ggplot(aes(x = bfgl, y = bfstan)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  facet_wrap(n ~ ploidy, scales = "free") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white", color = "black")) +
  xlab("Log BF from Gibbs Sampler") +
  ylab("Log BF from Stan") ->
  pl

ggsave(filename = "./output/gl/bf_compare_null.pdf",
       plot = pl,
       height = 6,
       width = 6,
       family = "Times")

gldf %>%
  filter(est, priorclass == "flex") %>%
  filter(condition == "alt") %>%
  mutate(n = as.factor(paste0("n = ", n)),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  ggplot(aes(x = bfgl, y = bfstan)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  facet_wrap(n ~ ploidy, scales = "free") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white", color = "black")) +
  xlab("Log BF from Gibbs Sampler") +
  ylab("Log BF from Stan") ->
  pl

ggsave(filename = "./output/gl/bf_compare_alt.pdf",
       plot = pl,
       height = 6,
       width = 6,
       family = "Times")

## Timing ----

gldf %>%
  filter(est, priorclass == "flex") %>%
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


## Different Genotype Likelihoods ----

gldf %>%
  select(n, ploidy, condition, est, priorclass, bfstan) %>%
  unite(col = "gl", sep = "_", priorclass, est) %>%
  mutate(gl = case_when(gl == "norm_FALSE" ~ "Oracle",
                        gl == "norm_TRUE" ~ "Norm",
                        gl == "unif_TRUE" ~ "Unif",
                        gl == "flex_TRUE" ~ "Flex")) %>%
  mutate(n = factor(n),
         ploidy = paste0("Ploidy = ", ploidy),
         gl = parse_factor(gl, levels = c("Oracle", "Norm", "Flex", "Unif")))  %>%
  mutate(condition = recode(condition,
                            "alt" = "Alt",
                            "null" = "Null")) %>%
  ggplot(aes(x = n, y = bfstan, color = gl)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot(outlier.size = 0.5) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  scale_color_colorblind(name = "Genotype\nLikelihoods") +
  geom_hline(yintercept = 0, lty = 2) +
  xlab("Sample Size") +
  ylab("Log Bayes Factor") ->
  pl

ggsave(filename = "./output/gl/gl_sens.pdf",
       plot = pl,
       height = 4,
       width = 6,
       family = "Times")

## QQ-plot of p-values from LRT approach ---
gldf %>%
  filter(condition == "null", est = TRUE, priorclass == "norm") %>%
  select(n, ploidy, p = p_mode) %>%
  group_by(n, ploidy) %>%
  arrange(p) %>%
  mutate(ts = as_tibble(ts_bands(n = n()))) %>%
  unnest(cols = "ts") %>%
  mutate(theo = -log(q),
         lower = -log(lower),
         upper = -log(upper),
         p = -p) %>%
  mutate(ploidy = str_c("K = ", ploidy),
         n = str_c("n = ", n)) %>%
  ggplot() +
  facet_wrap(ploidy ~ n, scales = "free") +
  geom_point(aes(x = theo, y = p)) +
  geom_ribbon(aes(x = theo, ymin = lower, ymax = upper), alpha = 1/4) +
  geom_abline(slope = 1, intercept = 0) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Theoretical Quantiles") +
  ylab("Empirical Quantiles") ->
  pl

ggsave(filename = "./output/gl/gl_qq_mode.pdf",
       plot = pl,
       height = 6,
       width = 6,
       family = "Times")
