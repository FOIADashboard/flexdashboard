# FOIA Annual Report Dashboard

This repository contains the code and data for the [FOIA Annual Report Dashboard](https://deportationresearch.shinyapps.io/FOIAdashboard/).

## Data

### RDS File

The dashboard uses data processed by the [FOIA data mining script](https://github.com/rcds-dssv/foia_data_mining). This script mines and process a collection of XLM files for a particular agency and converts to an `.rds` file. The file name follows the format `{agency}_data.rds`. The `{agency}` part should match exactly what's being used in the dashboard. For example, if the agency is `DHS`, the file name should be `DHS_data.rds`. More detail on using the script to process the data is available in the `instructions.md` file of the data mining repository.

Once the data is processed, move the `.rds` file to the `data/rds` directory. You should see that some data is already there. If you are updating an agency, replace the old file with the new one.

### CSV File

The budget data can be optionally included for each agency as a CSV file. This file is used to display statistics in the `Budget` tab of the dashboard.

The file name should follow the same convention: `{agency}_budget_ratio.csv`. The origin of these files are not clear, but Jackie's lab members should be able to track and provide them.

For the visualization in the `Budget` tab to display correctly, the CSV file should contain (at least) the following columns:

`Year`, `{component}_budget`, `{component}_ratio`, `{component}_backlog`

Where `{component}` is the name of the component of the agency. For example, if `DHS` has components `ICE` and `CBP`, the CSV file should contain at least

`Year`, `ICE_budget`, `ICE_ratio`, `ICE_backlog`, `CBP_budget`, `CBP_ratio`, `CBP_backlog`

The RDS files and CSV files work independently, so not all agencies need to be present in both formats.

## Dashboard

Code for the dashboard is in the `FOIAdashboard.Rmd` file.

The dashboard has three tabs: `FOIA METRICS`, `BUDGETS`, `ABOUT`. The `FOIA METRICS` tab uses the RDS files to display annual FOIA statistics for each agency. Here users can choose which section (data) to display, agency and components of interest, and years of interest. The `BUDGETS` tab uses the CSV files to display budget information for each agency. Similarly the users can choose agency and a component. The `ABOUT` tab contains information about the dashboard.

`functions.R` contains helper functions used in the dashboard. Function used to load and combine FOIA and budget data are included in this file. Plotting functions are also included here, which are used to create the plots in the dashboard.

### Configuration

General configuration of the dashboard is managed in the `global` code chunk (the first chunk in the dashboard). This chunk loads necessary packages, sources helper scripts, defines agencies, components, sections, and custom plot titles. Following are some important variables you may interact with often:

-   `agencies`: agencies to be displayed in the `FOIA METRICS` tab
-   `agencies_budget`: agencies to be displayed in the `BUDGETS` tab
-   `component_list`: list components for each agency
-   `section_choices`: available sections for each agency in the `FOIA METRICS` tab
-   `variable_choice_list`: how the variables in each sections should be displayed in the dropdown menu
-   `manual_title_list`: how the variable should be displayed in the plot title

### Update Process

Once new agency data is added to the `data/rds` or `data/csv` directory, the dashboard should be updated to reflect the new data. This is done by updating the `agencies` or `agencies_budget` variables in the `global` code chunk. You can choose to list the agency's components using the `component_list` variable. If the agency isn't specified in the `components_list` variable, then the dashboard will use all components included in the agency data.

If you are familiar with R, shiny, and flexdashboard, you can make changes to the dashboard code directly in the `FOIAdashboard.Rmd` file.

### Publishing App

The shiny app is hosted via [shinyapps.io](https://www.shinyapps.io/). To publish the app, you need to have the FOIA Dashboard shinyapps.io account setup. You can initiate the setup by clicking on the `Publish` button on the top right portion of the script pane in R Studio. Ask Killian Daly for the credentials to push the update.

When you publish the dashboard from your machine for the first time, you may be prompted to include the title for the dashboard. The title should be "FOIAdashboard".

When you update the code and once you feel that the updates are ready to be published online, click the `Publish` button. A pop up will appear and you can choose which files to include in the deployment. Select the following files: `FOIAdashboard.Rmd`, `foia_data.rds`, `budget_data.rds`, and `functions.R`. Once you have made the selection, click publish. Once the deployment is complete, [check the dashboard](https://deportationresearch.shinyapps.io/FOIAdashboard/) to confirm the updates.

