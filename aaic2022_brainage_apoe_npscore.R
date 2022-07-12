#' ---
#' title: "Sex differences of APOE neuropathology-based scores in brain aging"
#' author: "Nagesh Adluru"
#' output:
#'    html_document:
#'      toc: true
#'      toc_float: true
#' ---
#'
#' # Initialization
# Loading libraries ======
library(tidyverse)
library(numform)
library(lemon)
library(ggridges)
library(coin) 
library(RVAideMemoire)

# Initializing variables ======
rm(list = ls(all = T))
csvroot = 'CSVs/'
figroot = 'Figures/'

# ggplot theme =====
txtsize = 12
dodge = position_dodge(width = 0.9)
gtheme = theme(
  # legend
  legend.key = element_blank(),
  legend.title = element_blank(),
  legend.text = element_text(size = txtsize),
  legend.position = "top",
  legend.background = element_blank(),
  
  # text and axis
  strip.text.x = element_text(size = txtsize),
  strip.text.y = element_text(size = txtsize),
  axis.text = element_text(colour = "black",
                           size = txtsize),
  plot.title = element_text(size = txtsize, hjust = 0.5),
  axis.title = element_text(size = txtsize),
  axis.line = element_line(),
  strip.background = element_blank(),
  
  # panel
  panel.background = element_rect(fill = "white"),
  panel.grid.major = element_line(size = 0.2, linetype = 'solid',
                                  colour = "gray"), 
  panel.grid.minor = element_line(size = 0.05, linetype = 'solid',
                                  colour = "gray"),
  panel.border = element_blank(),
  
  # ticks
  axis.ticks.length = unit(0.25, "cm")
)

#' # figure 1 (in poster)
# loading the APOE npscores and TSAN brain age predictions =======
dfvis = read.csv(paste0(csvroot, 'n710_apoe_npscores.csv')) %>% distinct %>%
  inner_join(read.csv(paste0(csvroot, 'n710_tsan_brain_age.csv'))) %>% na.omit() %>% 
  group_by(reggieid, age) %>% 
  dplyr::summarise(ba = mean(prediction), n = n(), 
                   apoe_np = round(mean(apoe_npscore), digits = 2), 
                   sex = unique(sex), .groups = 'drop') %>% 
  filter(!apoe_np %in% c(-1.83, 3.29)) %>% 
  mutate(apoe_np_factor = as.character(apoe_np) %>% as.factor) %>% 
  filter(apoe_np_factor != '-1.83', apoe_np_factor != '3.29')

#+ fig.width=3.88, fig.height=3.75, warning=F
p = dfvis %>% ggplot(aes(x = ba - age, 
                         y = apoe_np_factor, 
                         linetype = sex)) + 
  stat_density_ridges(fill = NA, 
                      scale = 0.7, 
                      bandwidth = 2, 
                      quantile_lines = T, 
                      quantiles = 2, 
                      color = "gray50") + 
  gtheme + 
  theme(panel.grid.major.y = element_blank(), 
        panel.grid.minor.y = element_blank(), 
        panel.grid.minor.x = element_blank(), 
        axis.text.x = element_text(size = txtsize, 
                                   angle = 90, 
                                   vjust = 0.5), 
        axis.text.y = element_text(size = txtsize), 
        axis.title.x = element_text(size = txtsize, 
                                    hjust = 0.5), 
        axis.title.y = element_text(size = txtsize, 
                                    vjust = 1, 
                                    hjust = 0.5, 
                                    margin = margin(t = 0, 
                                                    r = -5, 
                                                    b = 0, 
                                                    l = 0)), 
        legend.margin = margin(t = 0, 
                               r = 0, 
                               b = 0, 
                               l = -65), 
        legend.text = element_text(size = txtsize, 
                                   hjust = 1), 
        panel.background = element_rect(fill = "transparent", 
                                        colour = NA), 
        plot.background = element_rect(fill = "transparent", 
                                       colour = NA), 
        legend.key = element_blank(), 
        legend.background = element_blank()) + 
  scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) + 
  coord_capped_cart(bottom = 'both', 
                    left = 'both') + 
  labs(y = '*APOE* npscore', 
       x = 'Excess aging of the brain age [y]') + 
  scale_linetype_manual(values = c(1, 2)) + 
  geom_text(data = dfvis %>% 
              filter(apoe_np_factor != '3.29') %>% 
              mutate(apoe_np_factor = apoe_np_factor %>% 
                       as.character %>% as.factor) %>% 
              group_by(apoe_np_factor, sex) %>% 
              dplyr::summarise(meba = round(median(ba - age), 1), 
                               .groups = 'drop') %>% 
              pivot_wider(names_from = sex, 
                          values_from = meba) %>% 
              filter(apoe_np_factor != '3.29'), 
            aes(x = 5, 
                y = as.numeric(apoe_np_factor) - 0.1, 
                label = paste0('F-M:', round(Female - Male, 1))), 
            parse = T, 
            size = 6, 
            hjust = 0.5, 
            inherit.aes = F, 
            alpha = 0.7)  + 
  theme(axis.title.y = ggtext::element_markdown()) + 
  geom_text(data = dfvis %>% 
              mutate(meba = ba - age) %>% 
              filter(apoe_np_factor != '3.29') %>% 
              group_by(apoe_np_factor) %>% 
              group_map(~mood.medtest(meba ~ sex, 
                                      data = .x) %>% 
                          broom::tidy() %>% 
                          cbind(.y)) %>% 
              bind_rows, aes(x = -6, 
                             y = as.numeric(apoe_np_factor) - 0.2, 
                             label = ifelse(p.value <= 0.05, '*', '')), 
            size = 10, inherit.aes = F) 
p
ggsave(paste0(figroot, 'brainage_apoenpscore.pdf'), 
       p, 
       width = 3.88, 
       height = 3.75)
