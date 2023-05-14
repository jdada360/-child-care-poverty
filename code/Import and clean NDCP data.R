# Set up =======================================================================
# This script aims to explore the National Database of Childcare Prices 
# 2008-2019.
#
#===============================================================================

setwd(
  here(
  BOX,
  "Child Care and Poverty/Data"
    )
  )

#============================== Import Data ==================================== 

## Import National Database of Childcare Prices 2008-2018 ======================

load("Raw data/National Database of Childcare Prices/2008-2018.rda")


## Clean National Database of Childcare Prices 2008-2018 =======================


# Removing flag variables

# Selecting variables to analyse 

ndcp_clean <-
  da38303.0001 %>% 
  tibble() %>% 
  clean_names() %>% 
  remove_all_labels() %>% 
  dplyr::select(
    state_name,
    state_abbreviation,
    county_name,
    county_fips_code,
    studyyear,
    pr_f,
    mhi,
    totalpop,
    me,
    fme,
    mme,
    contains("race"),
    hispanic,
    starts_with(c("h_","mc")),
    -ends_with("flag")
    ) %>% 
  rename("year" = "studyyear")


#============================== Descriptive Analysis =========================== 


## Load fonts

font_import()
loadfonts(device = "win")

## Yearly average of child care prices =========================================

fig1 <-
  ndcp_clean %>%
  group_by(year) %>% 
  summarise_at(
    c("mcsa",
      "mcinfant",
      "mctoddler",
      "mcpreschool"),
    ~ mean(.x, na.rm = TRUE)
  ) %>% 
  ungroup() %>% 
  pivot_longer(
    cols = c("mcsa",
             "mcinfant",
             "mctoddler",
             "mcpreschool"),
    names_to = "price_type",
    values_to = "price") %>% 
  mutate(
    price_type = case_when(
      price_type == "mcsa" ~ "School Age",
      price_type == "mcinfant" ~ "Infant",
      price_type == "mctoddler" ~ "Toddler",
      price_type == "mcpreschool" ~ "Preschool"),
    price_type =
      factor(
        price_type,
        levels = 
        c("Infant",
          "Toddler",
          "Preschool",
          "School Age"))
    ) %>% 
  apply_labels(
    year = "Study Year",
    price = "Average Median Price ($)",
    price_type = "Type of Center-Based \n Child Care") %>% 
  ggplot() +
  geom_point(aes(x = year,
                 y = price,
                 group = price_type,
                 color = price_type)) +
  geom_line(aes(x = year,
                y = price,
                group = price_type,
                color = price_type)) +
  theme_bw() +
  scale_x_continuous(
    breaks = 2008:2018,
    limits = c(2008, 2018)
  ) +
  easy_labs(title = "US Average Median Child Care Prices",
            subtitle = "2008-2018") + 
  theme(text = element_text(family = "Serif"),
        plot.title = element_text(size = 12, hjust = 0.5),
        plot.subtitle = element_text(size = 9 , hjust = 0.5, face = "italic"),
        plot.caption = element_text(face = "italic", hjust = 1),
        plot.margin = unit(c(0.75,0.75,0.75,0.75), "cm"),
        panel.grid.major.x =  element_line(color = "black",
                                           linewidth = 0.1,
                                           linetype="dashed"),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_line(color="black",
                                          linewidth = 0.1,
                                          linetype="dashed"),
        panel.grid.minor.y =  element_blank(),
        legend.title = element_text(size = 10, hjust = 0.5),
        legend.key.width = unit(1,"cm"),
        legend.text = element_text(size = 8),
        legend.key.size = unit(0.45, 'cm'),
        legend.background = element_rect(
          colour = 'black',
          fill = NA,
          linetype = 'solid'))
  
print(fig1)

## Quintiles of H_Under6_BothWork and Child care prices ========================

bothwork_df <-
  ndcp_clean %>% 
  group_by(state_name) %>% 
  mutate(across(
    c(ends_with("bothwork"),
      starts_with("mc")),
    ~ mean(.x, na.rm = TRUE))) %>% 
  ungroup() %>% 
  dplyr::select(-c("year", starts_with(c("county", "onerace", "i")),
                   "pr_f","mhi","me","mme", "hispanic")) %>% 
  distinct(state_name, h_under6_bothwork,
           h_6to17_bothwork, .keep_all = TRUE) %>% 
  mutate(across(
    ends_with("bothwork"),
    ~ xtile(.x, n = 10)
  ))  

# for (var in c("h_under_6bothwork",
#               "h_6to17_bothwork")){
# 
#   
# }


fig2 <-
  bothwork_df %>% 
  group_by(h_under6_bothwork) %>% 
  summarise_at(
    c("mcsa",
      "mcinfant",
      "mctoddler",
      "mcpreschool"),
    ~ mean(.x, na.rm = TRUE)
  ) %>% 
  ungroup() %>% 
  mutate(h_under6_bothwork = 
           factor(h_under6_bothwork,
                  levels = 1:10))%>% 
  pivot_longer(
    cols = c("mcsa",
             "mcinfant",
             "mctoddler",
             "mcpreschool"),
    names_to = "price_type",
    values_to = "price") %>% 
  mutate(
    price_type = case_when(
      price_type == "mcsa" ~ "School Age",
      price_type == "mcinfant" ~ "Infant",
      price_type == "mctoddler" ~ "Toddler",
      price_type == "mcpreschool" ~ "Preschool"),
    price_type =
      factor(
        price_type,
        levels = 
          c("Infant",
            "Toddler",
            "Preschool",
            "School Age"))
  ) %>% 
  apply_labels(
    h_under6_bothwork = "Deciles of Average Number of Households \n with Children Under 6 \n with Two Working Parents",
    price = "Average Median Price ($)",
    price_type = "Type of Center-Based \n Child Care") %>% 
  ggplot() +
  geom_point(
    aes(x = h_under6_bothwork,
        y = price,
        group = price_type,
        color = price_type)) +
  geom_line(aes(x = h_under6_bothwork,
                y = price,
                group = price_type,
                color = price_type)) +
  easy_labs(title = "US Child Care Prices by Deciles \n of Number of Households with Children \n Under 6 with Two Working Parents") +
  theme_bw() +
  theme(text = element_text(family = "Serif"),
        plot.title = element_text(size = 12, hjust = 0.5),
        plot.subtitle = element_text(size = 9 , hjust = 0.5, face = "italic"),
        plot.caption = element_text(face = "italic", hjust = 1),
        plot.margin = unit(c(0.75,0.75,0.75,0.75), "cm"),
        panel.grid.major.x =  element_line(color = "black",
                                           linewidth = 0.1,
                                           linetype="dashed"),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_line(color="black",
                                          linewidth = 0.1,
                                          linetype="dashed"),
        panel.grid.minor.y =  element_blank(),
        legend.title = element_text(size = 10, hjust = 0.5),
        legend.key.width = unit(1,"cm"),
        legend.text = element_text(size = 8),
        legend.key.size = unit(0.45, 'cm'),
        legend.background = element_rect(
          colour = 'black',
          fill = NA,
          linetype = 'solid'))
  

print(fig2)


## Race averages of child care prices ==========================================

fig2 <- 
  ndcp_clean %>% 
  group_by(state_name, county_name) %>% 
  mutate_at(vars(starts_with("onerace_")),
            ~ mean(.x, na.rm = TRUE)) %>% 
  pivot_longer(.,
               cols = c("onerace_w":"onerace_other"),
               names_to = "onerace_g",
               values_to = "onerace_p") %>% 
  ungroup() %>% 
  group_by(onerace_g) %>%
  mutate(p_quant = xtile(onerace_p, n = 5)) %>%
  ungroup() %>% 
  group_by(onerace_g, p_quant) %>% 
  summarise_at(vars(starts_with("mc")), mean,
               na.rm = TRUE) %>% 
  ungroup() %>% 
  mutate(p_quant = factor(p_quant,
                          levels = 1:5),
         onerace_g = factor(onerace_g,
                            levels = c("onerace_a",
                                       "onerace_b",
                                       "onerace_h",
                                       "onerace_i",
                                       "onerace_other",
                                       "onerace_w"),
                            labels = c("Asian",
                                       "Black",
                                       "Pacific Islander",
                                       "Native American",
                                       "Other",
                                       "White"))) %>% 
  filter(p_quant == 5)

for (var in colnames(fig1[,3:16])){

  fig <- 
    ggplot(data = fig1,
           aes(y = .data[[var]],
               x = reorder(onerace_g,
                           + .data[[var]]),
               color = onerace_g,
               fill = onerace_g)) +
      geom_bar(stat = "identity",
               width = 0.2) +
      theme_bw() +
      coord_flip() +
    labs(title = paste0(var),
         y =  paste0(var),
         x = "Counties in the top percentile of percentages of each race")
  
  print(fig)
  
}
 



