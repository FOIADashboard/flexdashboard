library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(ggplot2)
library(stringr)
library(scales)

create_foia_data <- function(agency_list) {
  agency_data <- list()
  
  if (!dir.exists("./data/rds")) {
    stop("./data/rds directory does not exist!")
  }
  
  for (agency in agency_list) {
    data_ <- readRDS(str_glue("./data/rds/{agency}_data.rds"))
    agency_data[[agency]] <- data_
  }
  
  saveRDS(agency_data, file = "foia_data.rds")
  
  return(agency_data)
}

load_foia_data <- function(agency_list=NULL) {
  foia_data_filename <- "foia_data.rds"
  
  if (!file.exists(foia_data_filename)) {
    foia_data <- create_foia_data(agency_list)
  } else {
    foia_data <- readRDS(foia_data_filename)
  }

  return(foia_data)
}

create_budget_data <- function(agency_list) {
  budget_data <- list()
  
  if (!dir.exists("./data/csv")) {
    stop("./data/csv directory does not exist!")
  }
  
  for (agency in agency_list) {
    budget_data[[agency]] <- readr::read_csv(str_glue("./data/csv/{agency}_budget_ratio.csv"))
  }

  saveRDS(budget_data, file = "budget_data.rds")
  
  return(budget_data)
}

load_all_agencies_budget <- function(agency_list=NULL) {
  budget_data_filename <- "budget_data.rds"
  
  if (!file.exists(budget_data_filename)) {
    budget_data <- create_budget_data(agency_list)
  } else {
    budget_data <- readRDS(budget_data_filename)
  }
  
  return(budget_data)
}

plot_single_column <- function(data, column_name, selected_components, selected_years, manual_titles = NULL, debug = FALSE) {
  
  if (debug) {
    print(head(data))
    print(column_name)
    print(selected_components)
    print(selected_years)
    print(manual_titles)
  }
  
  if (is.null(manual_titles)) {
    # Use automated titles
    plot_data <- data %>%
      filter(OrganizationAbbreviationText %in% selected_components, FY %in% selected_years) %>%
      select(FY, OrganizationAbbreviationText, !!sym(column_name)) %>%
      mutate(!!sym(column_name) := as.numeric(!!sym(column_name)))
    
    y_lab <- column_name
  } else {
    # Use manually defined titles
    plot_data <- data %>%
      filter(OrganizationAbbreviationText %in% selected_components, FY %in% selected_years) %>%
      select(FY, OrganizationAbbreviationText, !!sym(column_name)) %>%
      mutate(!!sym(column_name) := as.numeric(!!sym(column_name)))
    
    y_lab <- manual_titles
  }
  
  plot_data <- na.omit(plot_data)
  
  plot <- ggplot(plot_data, aes(x = FY, y = !!sym(column_name), color = OrganizationAbbreviationText, group = OrganizationAbbreviationText)) +
    geom_line(aes(text = paste("FY:", FY, "<br>", y_lab, ":", !!sym(column_name), "<br>Component:", OrganizationAbbreviationText))) +
    geom_point(aes(text = paste("FY:", FY, "<br>", y_lab, ":", !!sym(column_name), "<br>Component:", OrganizationAbbreviationText))) +
    labs(title = paste(y_lab, "for Selected Components"),
         y = y_lab,
         x = "FY",
         color = "Component") +
    theme_minimal() +
    theme(legend.position = "top") 
  
  
  return(ggplotly(plot, tooltip = "text")) #removing the auto-generated tooltip and opting for above
}

plot_budget_metrics <- function(data, selected_columns, selected_years, debug = FALSE) {
  if (debug) {
    print(head(data))
    print(selected_columns)
    print(selected_years)
  }
  
  plot_data <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, all_of(selected_columns)) %>%
    pivot_longer(cols = -Year, names_to = "Metric", values_to = "Value")
  
  plot_data$Value <- as.numeric(gsub(",", "", plot_data$Value))
  
  plot_data <- na.omit(plot_data)
  
  # Create a line plot using ggplot2
  plot <- ggplot(plot_data, aes(x = Year, y = Value/1e9, color = Metric)) +
    geom_point() +
    geom_line() +
    labs(title = "Budget Metrics",
         y = "Billions of Dollars ($)",
         x = "Year") +
    theme_minimal() +
    theme(legend.position = "top")
  
  return(ggplotly(plot))
}

plot_budget_ratio <- function(data, column_to_plot, selected_years) {
  
  all_missing <- all(is.na(data[[column_to_plot]]))
  if (all_missing) {
    return(NULL)
  }
  
  plot_data <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, all_of(column_to_plot)) %>%
    pivot_longer(cols = -Year, names_to = "Metric", values_to = "Value")
  
  # remove rows with missing values
  plot_data <- na.omit(plot_data)
  
  # Convert values to percentages
  plot_data$Value <- plot_data$Value * 100
  
  # Convert years to numeric
  selected_years <- as.numeric(selected_years)
  
  # Create a line plot using ggplot2
  plot <- ggplot(plot_data, aes(x = Year, y = Value, color = Metric, group = Metric)) +
    geom_point() +
    geom_line() +
    labs(title = paste("FOIA Budget / Total Budget (%)"),
         y = paste("FOIA/Total Budget (%)"),
         x = "Year") +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_x_continuous(
      breaks = breaks_pretty(),
      limits = c(min(selected_years), max(selected_years)))
  
  return(ggplotly(plot))
}

plot_backlog <- function(data, column_to_plot_backlog, selected_years) {
  
  all_missing <- all(is.na(data[[column_to_plot_backlog]]))
  if (all_missing) {
    return(NULL)
  }
  
  plot_data <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, all_of(column_to_plot_backlog)) %>%
    pivot_longer(cols = -Year, names_to = "Metric", values_to = "Value")
  
  # remove rows with missing values
  plot_data <- na.omit(plot_data)
  
  # Convert years to numeric
  selected_years <- as.numeric(selected_years)
  
  # Create a line plot using ggplot2
  plot <- ggplot(plot_data, aes(x = Year, y = Value, color = Metric, group = Metric)) +
    geom_point() +
    geom_line() +
    labs(title = paste("Component Backlog"),
         y = paste("Backlogged Requests"),
         x = "Year") +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_x_continuous(
      breaks = breaks_pretty(),
      limits = c(min(selected_years), max(selected_years)))
  
  return(ggplotly(plot))
}


plot_stacked_area <- function(data, column_names, selected_components, selected_years) {
  plot_data <- data %>%
    filter(OrganizationAbbreviationText %in% selected_components, FY %in% selected_years) %>%
    select(FY, OrganizationAbbreviationText, !!!syms(column_names)) %>%
    mutate(across(all_of(column_names), as.numeric))
  
  plot <- ggplot(plot_data, aes(x = FY, y = !!sym(column_names[1]), fill = OrganizationAbbreviationText)) +
    geom_area(position = "stack") +
    labs(title = paste("Stacked Area Chart of Selected Components"),
         y = "Value",
         x = "FY",
         fill = "OrganizationAbbreviationText",) +
    theme_minimal() +
    theme(legend.position = "top") 
  
  return(ggplotly(plot))
}

plot_two_columns_twoaxes <- function(data, selected_columns, selected_years) {
  selected_columns_expr <- rlang::syms(selected_columns)
  
  plot_data <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, !!!selected_columns_expr)
  
  #print(plot_data)
  
  for (col_name in selected_columns) {
    plot_data[[col_name]] <- as.numeric(gsub(",", "", plot_data[[col_name]]))
  }
  
  r1 <- diff(range(plot_data[[selected_columns[1]]]))
  
  r2 <- diff(range(plot_data[[selected_columns[2]]]))
  
  coeff <- r2/r1
  
  plot_data[[selected_columns[2]]] <- plot_data[[selected_columns[2]]]/coeff
  
  #plot_data <- na.omit(plot_data)
  
  
  plot <- ggplot(plot_data, aes(x = Year)) +
    geom_point(aes_string(y = selected_columns[1]), color = "blue") +
    geom_line(aes_string(y = selected_columns[1]), color = "blue") +
    geom_point(aes_string(y = selected_columns[2]), color = "red") +
    geom_line(aes_string(y = selected_columns[2]), color = "red") +
    scale_y_continuous(name = selected_columns[1], sec.axis = sec_axis(~.*coeff, name = selected_columns[2])) +
    labs(title = "Budget Metrics",
         y = "USD ($)",
         x = "Year") +
    theme_minimal() +
    theme(legend.position = "top",
          axis.title.y = element_text(color = "blue"),     # Color for y1-axis title
          axis.title.y.right = element_text(color = "red") # Color for y2-axis title
    )
  
  
  return(plot)
}

