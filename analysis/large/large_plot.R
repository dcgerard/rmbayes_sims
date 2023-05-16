library(tidyverse)
library(ggthemes)
library(hwep)
library(latex2exp)

ldf <- readRDS("./output/large_samp/ldf.RDS")

## Sensitivity analysis plot
ldf %>%
  filter(condition == "alt" | condition == "null") %>%
  mutate(n = factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  mutate(condition = recode(condition,
                            "alt" = "Alt",
                            "null" = "Null")) %>%
  select(n, ploidy, condition, a_auto = bf, a_allo = bf_allo, a1 = bf_low, a2 = bf_high, a3 = bf_weird) %>%
  gather(key = "prior", value = "bf", a_auto, a_allo, a1, a2, a3) %>%
  mutate(prior = recode(prior,
                        "a_auto" = "alpha[auto]",
                        "a_allo" = "alpha[allo]",
                        "a1" = "alpha[1]",
                        "a2" = "alpha[2]",
                        "a3" = "alpha[3]"),
         prior = parse_factor(prior)) %>%
  ggplot(aes(x = n, y = bf, color = prior)) +
  geom_boxplot(outlier.size = 0.5) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("Log Bayes Factor") +
  xlab("Sample Size") +
  scale_color_colorblind(name = "Prior", labels = scales::parse_format()) +
  theme(legend.text.align = 0) ->
  pl

ggsave(filename = "./output/large_samp/bf_sensitive.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")

## Bayes factor plot
ldf %>%
  filter(condition == "alt" | condition == "null") %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  mutate(condition = recode(condition,
                            "alt" = "Alt",
                            "null" = "Null")) %>%
  ggplot(aes(x = n, y = bf)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("Log Bayes Factor") +
  xlab("Sample Size") ->
  pl

ggsave(filename = "./output/large_samp/bf_large.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")

## p-value plot
ldf %>%
  filter(condition == "alt" | condition == "null") %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  mutate(condition = recode(condition,
                            "alt" = "Alt",
                            "null" = "Null")) %>%
  ggplot(aes(x = n, y = p)) +
  facet_grid(condition ~ ploidy, scales = "free_y") +
  geom_boxplot() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_hline(yintercept = 0, lty = 2, col = 2) +
  ylab("Log p-value") +
  xlab("Sample Size") ->
  pl

ldf %>%
  mutate(ploidy = str_c("K = ", ploidy),
         n = str_c("n = ", n)) %>%
  filter(condition == "null") %>%
  mutate(p = exp(p)) %>%
  select(n, ploidy, p) %>%
  group_by(n, ploidy) %>%
  summarize(ksp = ks.test(p, y = punif)$p.value) %>%
  mutate(ksp = format(ksp, digits = 2)) ->
  ksdf

ldf %>%
  filter(condition == "null") %>%
  select(n, ploidy, p) %>%
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
  facet_grid(ploidy ~ n) +
  geom_point(aes(x = theo, y = p)) +
  geom_ribbon(aes(x = theo, ymin = lower, ymax = upper), alpha = 1/4) +
  geom_abline(slope = 1, intercept = 0) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Theoretical Quantiles") +
  ylab("Empirical Quantiles") +
  geom_label(data = ksdf, aes(label = ksp), x = 1.5, y = 13) ->
  pl

ggsave("./output/large_samp/qqpvalue.pdf", height = 6, width = 6, family = "Times")

ldf %>%
  filter(condition == "null") %>%
  select(n, ploidy, p) %>%
  mutate(p = exp(p)) %>%
  ggplot(aes(x = p)) +
  geom_histogram(bins = 10) +
  facet_grid(ploidy ~ n) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Theoretical Quantiles") +
  ylab("Empirical Quantiles") ->
  pl

## Time plot
ldf %>%
  filter(condition == "alt" | condition == "null") %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy)) %>%
  mutate(condition = recode(condition,
                            "alt" = "Alt",
                            "null" = "Null")) %>%
  gather(key = "Method", value = "Time", bf_time, p_time) %>%
  mutate(Method = recode(Method, "bf_time" = "Bayes", "p_time" = "LRT")) %>%
  ggplot(aes(x = n, y = Time, color = Method)) +
  facet_grid(condition ~ ploidy) +
  geom_boxplot(outlier.size = 0.3) +
  theme_bw() +
  ylab("Time (seconds)") +
  xlab("Sample Size") +
  scale_y_log10() +
  scale_color_colorblind() +
  theme(strip.background = element_rect(fill = "white")) ->
  pl

ggsave(filename = "./output/large_samp/time_large.pdf",
       plot = pl,
       height = 3,
       width = 6,
       family = "Times")
