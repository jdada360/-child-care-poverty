# Set the working directory 

setwd(file.path(path, "Data"))


#============================== Import Data ===================================# 

# # # Import National Database of Childcare Prices 2008-2018 # # #

ndcp_raw <- CCMHr::loadRDa("Raw data/National Database of Childcare Prices/2008-2018.rda")


# # # Clean National Database of Childcare Prices 2008-2018 # # # 


# Removing flag variables

# Selecting variables to analyse 


ndcp_clean <-
  ndcp_raw %>% 
  clean_names() %>% 
  remove_all_labels()


