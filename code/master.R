#===============================================================================
# This script sets up the directory and loads the necessary packages to run the
# analysis.
#===============================================================================

# Change to Box folder on your computer

BOX <- Sys.getenv("BOX") 

# Load necessary packages

require("pacman")

packages <-
  c("tidyverse",
    "ggplot2",
    "readxl",
    "haven",
    "tidyr",
    "openxlsx",
    "remotes",
    "janitor",
    "expss",
    "dplyr",
    "statar",
    "dataReporter",
    "here",
    "ggeasy",
    "extrafont",
    "sjlabelled",
    "wesanderson"
  )

pacman::p_load(
  packages,
  character.only = TRUE
)