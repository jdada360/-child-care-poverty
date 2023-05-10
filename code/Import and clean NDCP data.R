# Set the working directory 

setwd(
  file.path(
  BOX,
  "Child Care and Poverty/Data"
    )
  )

#============================== Import Data ==================================== 

##============ Import National Database of Childcare Prices 2008-2018 ==========

load("Raw data/National Database of Childcare Prices/2008-2018.rda")


# # # Clean National Database of Childcare Prices 2008-2018 # # # 


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


fig1 <- 
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
 



