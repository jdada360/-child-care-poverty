# Set the working directory 

setwd(file.path(path, "Data"))


#============================== Import Data ===================================# 

# # # Import National Database of Childcare Prices 2008-2018 # # #

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


#============================== Descriptive Analysis ============================# 


fig1 <- 
  ndcp_clean %>% 
  group_by(state_name, county_name, year) %>% 
  mutate(onerace_ba = onerace_b + onerace_a) %>%
  ungroup() %>% 
  group_by(state_name, county_name) %>% 
  mutate_at(vars(starts_with("onerace_")),
            ~ mean(.x, na.rm = TRUE)) %>% 
  pivot_longer(.,
               cols = c("onerace_w":"onerace_other","onerace_ba"),
               names_to = "onerace_g",
               values_to = "onerace_p") %>% 
  ungroup() %>% 
  group_by(onerace_g) %>%
  mutate(p_quant = xtile(onerace_p, n = 5)) %>% 
  group_by(onerace_g, p_quant) %>% 
  summarise(mcpreschool = mean(mcpreschool, na.rm = TRUE))
  
  filter(onerace_group != "onerace_w") %>% 
  ggplot() +
  geom_point(aes(y = mcsa,
                 x = onerace_p,
                 group = onerace_group,
                 color = onerace_group)) +
  geom_line(aes(y = mcsa,
                x = onerace_p,
                group = onerace_group,
                color = onerace_group),
            linewidth = 0.5) +
  theme_bw() 




