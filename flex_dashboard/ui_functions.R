sidebar_text_list_1 <- list(
  top = HTML(
    "<br/><br/><p>
      The dashboard displays the data from the Freedom of Information Act (FOIA) Annual Reports released each year by federal agencies and their components. 
      The sources for the department and component annual budgets data are available <a href=\"https://www.justice.gov/oip/reports-1\">here</a>. The sections of the Annual Reports are accessible via the top panel.
      </p>
      <p>Please select data type, component agency(s), and fiscal year(s) below.</p>"
  ),
  bottom = HTML(
    "
    <br/>For more information about the FOIA, see <a href=\"https://www.foia.gov\">foia.gov</a>.
    <br/>
    <br/>
    Created by <a href=\"https://deportation-research.buffett.northwestern.edu/people/\">Kendall McKay</a> for the <a href=\"https://deportation-research.buffett.northwestern.edu\">Deportation Research Clinic</a>.
    <br/>
    <br/>
    Project support provided by <a href=\"https://faculty.wcas.northwestern.edu/aaron-geller/\">Aaron Geller</a> and <a href=\"https://www.linkedin.com/in/patrick-zacher/\">Patrick Zacher</a> of Northwestern University's <a href=\"https://www.it.northwestern.edu/departments/it-services-support/research/\">IT Research Computing and Data Services (RCDS)</a>.
    <br/>
    <br/>
    Funding provided by the Northwestern University <a href=\"https://www.ipr.northwestern.edu\">Institute for Policy Research (IPR)</a>.
    <br/>
    <br/>
    <div style=\"font-size: smaller;\">Jacqueline Stevens and Kendall McKay, FOIA Dashboard, <a href=\"https:/deportationresearch.shinyapps.io/FOIAdashboard/\">https:/deportationresearch.shinyapps.io/FOIAdashboard/</a>
    Copyright: <a href=\"https://creativecommons.org/licenses/by-nc/4.0/\">CC BY-NC</a> </div>
    "
  )
)

sidebar_text_list_budgets <- list(
  top = HTML(
    "
    <br>
    <br>
    <br>
    The <a href=\"https://deportation-research.buffett.northwestern.edu/\">Deportation Research Clinic's</a>
    dashboard displays the data from the Freedom of Information Act (FOIA) Annual Reports released 
    each year by federal agencies and their components. Access the Annual Reports 
    <a href=\"https://www.justice.gov/oip/reports-1\">here</a>. The dashboard's tabs reflect several of the categories of the Annual Reports.
    <br>
    <br>
    The sources for the budget data are accessible <a href=\"https://docs.google.com/spreadsheets/d/1CV6Z_gTZ0KVZ84ChH9lS88vAB-SyuqvRFO_Mavl7NDw/edit?usp=sharing\">here</a>.
    <br>
    <br>
    Please select data type, component agency(s), and fiscal year(s) below.
    <br>
    <br>
    "
  ),
  bottom = HTML(
    "<br/>For more information about the FOIA, see <a href\"https://www.foia.gov\">foia.gov</a>."
  )
)

# not used in the dashboard
ui_function <- function(
    section_agency_id, 
    section_component_id, 
    section_fy_id,
    custom_column_select_ui,
    sidebar_text_list,
    agencies = c("DHS", "EPA", "DOL", "DOJ", "DOS", "HHS"),
    component_select_ui = NULL) {
  
  # allow custom component selection UI
  if (is.null(component_select_ui)) {
    component_select_ui <- checkboxGroupInput(
      section_component_id,
      "Component",
      choices = c("CBP", "PRIV", "USCIS", "ICE", "OIG", "CRCL"), 
      selected = c("CBP", "PRIV")
    )
  }
  
  tagList(
    # Top Text
    sidebar_text_list$top, 
    
    # Agency selection
    selectInput(section_agency_id, "Agency", 
                choices = agencies, 
                selected = "DHS"),
    
    # Data (column) selection
    custom_column_select_ui,
    
    # Component selection
    component_select_ui,
    
    checkboxGroupInput(
      section_fy_id, "FY", 
      choices = c("10", "11", "12", "13", "14", "15", 
                  "16", "17", "18", "19", "20", "21", 
                  "22","23"), 
      selected = c("10", "11", "12", "13", "14", "15", 
                   "16", "17", "18")),
    
    # Bottom Text
    sidebar_text_list$bottom
  )
}