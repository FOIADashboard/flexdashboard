ui_function <- function(
    section_agency_id, 
    section_component_id, 
    section_fy_id,
    custom_column_select_ui, 
    agencies = c("DHS", "EPA", "DOL", "DOJ", "DOS", "HHS"),
    component_select_function = checkboxGroupInput) {
  
  tagList(
    # 
    HTML(
      "<br/><br/><p>
      The dashboard displays the data from the Freedom of Information Act (FOIA) Annual Reports released each year by federal agencies and their components. 
      The sources for the department and component annual budgets data are available <a href=\"https://www.justice.gov/oip/reports-1\">here</a>. The sections of the Annual Reports are accessible via the top panel.
      </p>
      <p>Please select agency, component/region, data type, and fiscal year below.</p>"
    ), 
    # Agency selection
    selectInput(section_agency_id, "Agency", 
                choices = agencies, 
                selected = "DHS"),
    
    # Data (column) selection
    custom_column_select_ui,
    
    # Component selection
    component_select_function(
      section_component_id,
      "Component",
      choices = c("CBP", "PRIV", "USCIS", "ICE", "OIG", "CRCL"), 
      selected = c("CBP", "PRIV")
    ),
    
    checkboxGroupInput(
      section_fy_id, "FY", 
      choices = c("10", "11", "12", "13", "14", "15", 
                  "16", "17", "18", "19", "20", "21", 
                  "22","23"), 
      selected = c("10", "11", "12", "13", "14", "15", 
                   "16", "17", "18")),
    
    HTML(
      "<br/>For more information about the FOIA, see [foia.gov](https://www.foia.gov).
      <br/>
  Created by [Kendall McKay](https://deportation-research.buffett.northwestern.edu/people/) for the [Deportation Research Clinic](https://deportation-research.buffett.northwestern.edu).
  <br/>
  <br/>
  <br/>
  Project support provided by [Aaron Geller](https://faculty.wcas.northwestern.edu/aaron-geller/) and [Patrick Zacher](https://www.linkedin.com/in/patrick-zacher/) of Northwestern University's [IT Research Computing and Data Services (RCDS)](https://www.it.northwestern.edu/departments/it-services-support/research/).
  <br/>
  <br/>
  <br/>
  Funding provided by the Northwestern University [Institute for Policy Research (IPR)](https://www.ipr.northwestern.edu).
  
  <br/>
  <div style=\"font-size: smaller;\">Jacqueline Stevens and Kendall McKay, FOIA Dashboard, https:/deportationresearch.shinyapps.io/FOIAdashboard/ 
  Copyright: <a href=\"https://creativecommons.org/licenses/by-nc/4.0/\">CC BY-NC</a> </div>"
    ))
}