library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(ggplot2)
library(stringr)
library(scales)
library(purrr)

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

extract_agency_components <- function(foia_data) {
  foia_data %>% 
    map(~ unique(.x$OrganizationAbbreviationText)) %>%
    flatten_chr() %>% 
    unique() %>%
    sort()
}

load_foia_data <- function(agency_list=NULL) {
  foia_data_filename <- "foia_data.rds"
  
  if ((!file.exists(foia_data_filename)) | dir.exists("data/rds/")) {
    # save foia data object if it doesn't exist
    foia_data <- create_foia_data(agency_list)
  } else {
    foia_data <- readRDS(foia_data_filename)
    # check that the foia data object is up to date
    if (!all(agency_list %in% names(foia_data))) {
      foia_data <- create_foia_data(agency_list)
    }
  }

  return(foia_data)
}

create_budget_data <- function(agency_list) {
  
  budget_data_filename <- "data/FOIA Dashboard Government Budgets.xlsx"
  
  if (!file.exists(budget_data_filename)) {
    stop(str_glue("{budget_data_filename} file does not exist!"))
  }
  
  names(agency_list) <- agency_list
  
  sheet_names <- excel_sheets(budget_data_filename)
  
  if (!all(agency_list %in% sheet_names)) {
    missing_agency <- paste(setdiff(agency_list, sheet_names), collapse = ", ")
    stop(str_glue("Excel budget file missing some agencies: {missing_agency}"))
  }
  
  budget_data <- map(agency_list, ~ read_xlsx(budget_data_filename, .x))
  
  saveRDS(budget_data, file = "budget_data.rds")
  
  return(budget_data)
}

load_all_agencies_budget <- function(agency_list=NULL) {
  
  budget_xlsx_filename <- "data/FOIA Dashboard Government Budgets.xlsx"
  budget_data_filename <- "budget_data.rds"
  
  if ((!file.exists(budget_data_filename)) | file.exists(budget_xlsx_filename)) {
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
  
  # plot no data plot if no remaining data
  if (nrow(plot_data) == 0) {
    return(plot_no_data())
  }
  
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

plot_budget_metrics <- function(
    data, selected_columns, selected_years,
    selected_agency, selected_component,
    debug = FALSE) {
  
  if (debug) {
    print(head(data))
    print(selected_columns)
    print(selected_years)
  }
  
  if (!(selected_columns %in% colnames(data))) {
    warning(str_glue("Column {selected_columns} not found in dataset."))
    return(plot_no_data())
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
    geom_line(show.legend=FALSE) +
    labs(
      title = str_c(
        "Budget Metrics - ",
        "Agency: ", selected_agency,
        ", Component: ", selected_component
      ),
      y = "Billions of Dollars ($)",
      x = "Year"
    ) +
    theme_minimal() +
    theme(legend.position = "none")
  
  return(ggplotly(plot))
}

plot_budget_ratio <- function(data, column_to_plot, selected_years, component, line_color = "F8766D") {
  
  all_missing <- all(is.na(data[[column_to_plot]]))
  if (all_missing) {
    return(NULL)
  }
  
  # Need to also extract {component}_foiacost and {component}_budget
  plot_data <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, all_of(c(column_to_plot))) %>%
    pivot_longer(cols = -Year, names_to = "Metric", values_to = "Value")
  data_for_text <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, any_of(paste0(component, c("_foiacost", "_budget"))))
  
  # create column "XXX" if it doesn't exist for data_for_text
  if (!(paste0(component, "_foiacost") %in% colnames(data_for_text))) {
    data_for_text[["foiacost"]] <- ""
  } else {
    data_for_text[["foiacost"]] <- data_for_text[[paste0(component, "_foiacost")]] 
  }
  if (!(paste0(component, "_budget") %in% colnames(data_for_text))) {
    data_for_text[["budget"]] <- ""
  } else {
    data_for_text[["budget"]] <- data_for_text[[paste0(component, "_budget")]]
  }
  
  data_for_text <- data_for_text %>%
    mutate(
      cost_text = str_glue("FOIA Expenditures ($): {format(foiacost, format=\"d\", big.mark=\",\")}\nAgency Budgetary Resources ($): {format(budget, format=\"d\", big.mark=\",\")}")
    )
  
  plot_data <- plot_data %>% 
    left_join(data_for_text, by = "Year")
  
  # remove rows with missing values
  plot_data <- na.omit(plot_data)
  
  # Convert values to percentages
  plot_data <- plot_data %>%
    mutate(
      Value = Value,
      perc_formatted = format(Value*100, digits = 2, scientific = FALSE),
      text = str_glue(
        "Year: {Year}\nPercent: {perc_formatted}%\n{cost_text}")
    )
  
  # Convert years to numeric
  selected_years <- as.numeric(selected_years)
  
  # Create a line plot using ggplot2
  plot <- ggplot(plot_data, aes(x = Year, y = Value*100, color = Metric)) +
    geom_point(aes(text = text)) +
    geom_line() +
    labs(title = paste("FOIA Budget / Total Budget (%)"),
         y = paste("Percent Total Budget"),
         x = "Year") +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_x_continuous(
      breaks = breaks_pretty(),
      limits = c(min(selected_years), max(selected_years))) +
    scale_color_manual(values = set_names(line_color, column_to_plot)) +
    scale_y_continuous(labels = function(x) paste0(format(x, scientific = FALSE), "%"))
  
  return(ggplotly(plot, tooltip = "text"))
}

plot_backlog <- function(data, column_to_plot_backlog, selected_years, line_color = "#F8766D") {
  
  all_missing <- all(is.na(data[[column_to_plot_backlog]]))
  if (all_missing) {
    return(NULL)
  }
  
  plot_data <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, all_of(column_to_plot_backlog)) %>%
    pivot_longer(cols = -Year, names_to = "Metric", values_to = "Value") %>%
    mutate(
      text = str_glue(
        "Year: {Year}\nBacklogged Requests: {format(Value, format=\"d\", big.mark=\",\")}"
      )
    )
  
  # remove rows with missing values
  plot_data <- na.omit(plot_data)
  
  # Convert years to numeric
  selected_years <- as.numeric(selected_years)
  
  # Create a line plot using ggplot2
  plot <- ggplot(plot_data, aes(x = Year, y = Value, color = Metric, group = Metric)) +
    geom_point(aes(text = text)) +
    geom_line() +
    labs(title = paste("Component Backlog"),
         y = paste("Backlogged Requests"),
         x = "Year") +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_x_continuous(
      breaks = breaks_pretty(),
      limits = c(min(selected_years), max(selected_years))) +
    scale_color_manual(values = set_names(line_color, column_to_plot_backlog))
  
  return(ggplotly(plot, tooltip = "text"))
}

plot_ratio_v_backlog <- function(
    filtered_data_b,
    component,
    agencyBudget_year,
    line_colors = c("red", "blue"),
    plot_title = "Budgets Ratio vs. Backlogged Requests"
) {
  # stack two plots. The top plot is a budget ratio plot and the bottom plot
  # is the number of backlogs
  
  filtered_input_b_ratio <- str_glue("{component}_ratio")
  filtered_input_b_backlog <- str_glue("{component}_backlog")
  
  if (filtered_input_b_ratio %in% colnames(filtered_data_b)){
    p1 <- plot_budget_ratio(
      filtered_data_b,
      filtered_input_b_ratio,
      agencyBudget_year,
      component,
      line_color = line_colors[1])
    if (is.null(p1)) {
      p1 <- plot_no_data() %>%
        ggplotly()
    }
  } else {
    warning(str_glue("Column {filtered_input_b_ratio} not found in dataset."))
    p1 <- plot_no_data() %>%
      ggplotly()
  }
  
  if (filtered_input_b_backlog %in% colnames(filtered_data_b)){
    p2 <- plot_backlog(
      filtered_data_b,
      filtered_input_b_backlog,
      agencyBudget_year,
      line_color = line_colors[2])
    if (is.null(p2)) {
      p2 <- plot_no_data() %>%
        ggplotly()
    }
  } else {
    warning(str_glue("Column {filtered_input_b_backlog} not found in dataset."))
    p2 <- plot_no_data() %>% 
      ggplotly()
  }
  
  subplot(p1, p2, nrows = 2, shareX = TRUE, shareY = FALSE, titleY = TRUE) %>%
    layout(title = plot_title)
}

plot_no_data <- function() {
  # use this plot whenever a required column is missing for a plot
  ggplot() +
    annotate(label = "Insufficient data for this agency / component", 
             x = 0, y = 0, geom = "text", size = 8) +
    theme_void()
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
         fill = "OrganizationAbbreviationText") +
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

plot_publicaffairs_ratio <- function(
    data,
    component,
    selected_years, 
    line_color = "#F8766D"
) {
  # function to plot the ratio between public affairs and foia expenditure
  
  foiacost_colname <- str_c(component, "_foiacost")
  publicaffairs_colname <- str_c(component, "_publicaffairscost")
  
  if (!all(c(foiacost_colname, publicaffairs_colname) %in% colnames(data))) {
    ggplot() +
      annotate(label = "Missing foiacost or publicaffairscost column for this agency / component", 
               x = 0, y = 0, geom = "text", size = 8) +
      theme_void()
  }
  plot_data <- data %>%
    filter(Year %in% selected_years) %>%
    select(Year, all_of(c(foiacost_colname, publicaffairs_colname))) %>%
    rename_with(.fn = ~ str_extract(.x, pattern = "[[:alpha:]]+$"), .cols = contains("_")) %>%
    mutate(
      Value = publicaffairscost / foiacost,
      Metric = "Public Affairs Ratio",
      text = str_c(
        str_glue("Year: {Year}"),
        str_glue("Percent: {format(Value*100, digits = 2, scientific = FALSE)}%"),
        str_glue("Public Affairs Expenditures ($): {format(publicaffairscost, format=\"d\", big.mark=\",\")}"),
        str_glue("FOIA Expenditures ($): {format(foiacost, format=\"d\", big.mark=\",\")}"),
        sep = "\n"
      )
    )
  
  # remove rows with missing values
  plot_data <- na.omit(plot_data)
  
  # Convert years to numeric
  selected_years <- as.numeric(selected_years)
  
  # Create a line plot using ggplot2
  plot <- ggplot(plot_data, aes(x = Year, y = Value*100, color = Metric)) +
    geom_point(aes(text = text)) +
    geom_line() +
    labs(title = paste("Public Affairs / Total Budget (%)"),
         y = paste("Percent Total Budget"),
         x = "Year") +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_x_continuous(
      breaks = breaks_pretty(),
      limits = c(min(selected_years), max(selected_years))) +
    scale_color_manual(values = set_names(line_color, "Public Affairs Ratio")) +
    scale_y_continuous(labels = function(x) paste0(format(x, scientific = FALSE), "%"))
  
  return(ggplotly(plot, tooltip = "text"))
}
