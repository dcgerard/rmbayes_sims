#####################
## Plot results of gl simulations
#####################

library(tidyverse)
library(ggthemes)

gldf <- readRDS("./output/gl/gldf.RDS")

gldf %>%
  mutate(n = as.factor(n),
         ploidy = paste0("Ploidy = ", ploidy),
         bf = bfgl) %>%
  select(n, ploidy, condition, bf_mean, bfgl) %>%
  gather(bf_mean, bfgl, key = "Method", value = "bf") %>%
  mutate(simv = case_when(condition == "null" & Method == "bf_mean" ~ "Null, Known",
                          condition == "null" & Method == "bfgl" ~ "Null, GL",
                          condition == "alt" & Method == "bf_mean" ~ "Alt, Known",
                          condition == "alt" & Method == "bfgl" ~ "Alt, GL")) %>%
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
