
template_ui_1 <- function(
  id,
  section_agency_id,
  section_component_id,
  section_fy_id,
  column_select_ui
) {
  ns <- NS(id)
  
  ui_function(
    section_agency_id = ns(section_agency_id), 
    section_component_id = ns(section_component_id), 
    section_fy_id = ns(section_fy_id), 
    custom_column_select_ui = column_select_ui)
}
