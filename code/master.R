#===============================================================================
# This script sets up the directory and loads the necessary packages to run thee
# analysis.
#
#===============================================================================

# Change to Box folder on your computer

path <- "/Users/joydada/Library/CloudStorage/Box-Box/Child Care and Poverty"

# Load necessary packages

packages <-
  c("tidyverse",
    "ggplot2",
    "readxl",
    "haven",
    "tidyr",
    "openxlsx",
    "remotes",
    "janitor",
    "sjlabelled"
  )

pacman::p_load(
  packages,
  character.only = TRUE
)