library(flexdashboard)
library(shiny)
library(knitr)
library(kableExtra)
library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(ggplot2)
library(stringr)
library(readr)
library(scales)

# load functions used in script
source("functions.R")
source("ui_functions.R")

# global variables
rds_dir <- "data/rds"
csv_dir <- "data/csv"

master_budget_data <- load_all_agencies_budget(
  c("DHS", "DOL", "DOJ", "HHS", "DOS"), data_dir = csv_dir)
master_foia_data <- load_all_agencies(
  c("DHS", "DOL", "DOJ", "HHS", "DOS"), data_dir = rds_dir)

agency <- "DHS"
selected_columns <- "OIG_backlog"
selected_years <- 2013:2023
