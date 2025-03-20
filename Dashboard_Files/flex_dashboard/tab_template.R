
# UI ----------------------------------------------------------------------

# define variables for section
# update the IDs, change the list variable name, 
# then replace the variables with ctrl + f
{DATA_LIST} <- list(
  agency_id = "___________Agency",
  component_id = "__________Component",
  fy_id = "____________FY",
  column_id = "____________"
)

# column select UI. Update the variable name
{COLUMN_SELECT_UI} <- selectInput(
  {DATA_LIST}$column_id, "PLACEHOLDER", 
  choices = c(
    "PLACEHOLDER" = "PLACEHOLDER"
  ), 
  selected = "PLACEHOLDER")

# create UI. Update the variables
ui_function(
  section_agency_id = {DATA_LIST}$agency_id, 
  section_component_id = {DATA_LIST}$component_id, 
  section_fy_id = {DATA_LIST}$fy_id, 
  custom_column_select_ui = {COLUMN_SELECT_UI},
  agencies = c("DHS", "EPA", "DOL", "DOS")
)

# Server ------------------------------------------------------------------
# Reactive values list to hold the inputs
# Update the variable name and the variables inside observe({})
{INPUT_VALUES} <- reactiveValues()

observe({
  {INPUT_VALUES}$agency <- input[[{DATA_LIST}$agency_id]]
  {INPUT_VALUES}$component <- input[[{DATA_LIST}$component_id]]
  {INPUT_VALUES}$fy <- input[[{DATA_LIST}$fy_id]]
  {INPUT_VALUES}$data <- input[[{DATA_LIST}$column_id]]
  {INPUT_VALUES}$component_input_id <- {DATA_LIST}$component_id
})

# Update filtered data variable name
{FILTERED_DATA} <- reactive({
  req({INPUT_VALUES}$agency)
  load_foia(
    input_data = {INPUT_VALUES}$agency,
    possible_agencies = agencies,
    section_name = "PLACEHOLDER"
  )
})

# update component selection
observe({
  req({INPUT_VALUES}$agency)
  updateCheckboxGroupInput(
    session, {INPUT_VALUES}$component_input_id, "Component",
    choices = component_list[[{INPUT_VALUES}$agency]],
    selected = component_list[[{INPUT_VALUES}$agency]][c(1,2)]
  )
})

# Maps the column name to the plot title
{MANUAL_TITLE_EXPEDITED} <- reactive({
  if ({INPUT_VALUES}$data == "RequestGrantedQuantity") {
    return("Adjudication Requests Granted")
  } else if ({INPUT_VALUES}$data == "RequestDeniedQuantity") {
    return("Adjudication Requests Denied")
  } else if ({INPUT_VALUES}$data == "AdjudicationMedianDaysValue") {
    return("Median Adjudication (Days)")
  } else if ({INPUT_VALUES}$data == "AdjudicationAverageDaysValue") {
    return("Average Adjudication (Days)")
  } else if ({INPUT_VALUES}$data == "AdjudicationWithinTenDaysQuantity") {
    return("Requests Adjudicated Within Ten Days")
  } else {
    return(NULL)  # Return NULL if no match is found
  }
})

renderPlotly({
  plot_single_column(
    isolate({FILTERED_DATA}()),
    {INPUT_VALUES}$data,
    {INPUT_VALUES}$component,
    {INPUT_VALUES}$fy,
    manual_title = {MANUAL_TITLE_EXPEDITED}()
  )
})
