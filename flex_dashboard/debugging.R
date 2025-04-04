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

# load functions used in script
source("functions.R")
source("ui_functions.R")

# global variables
rds_dir <- "data/rds"
csv_dir <- "data/csv"

master_budget_data <- load_all_agencies_budget(
  c("DHS", "DOL", "DOJ", "HHS", "DOS"), data_dir = csv_dir)

agency <- "DHS"
column_to_plot_budget <- "CRCL_ratio"
column_to_plot_backlog <- "CRCL_backlog"
selected_years <- 2013:2023

p1 <- plot_single_column_budget(
  master_budget_data[[agency]],
  column_to_plot_backlog,
  selected_years
)
p2 <- plot_single_column_backlog(master_budget_data[[agency]], column_to_plot_backlog, selected_years)

subplot(p1, p2, nrows = 2, shareX = TRUE, shareY = FALSE, titleY = TRUE)
