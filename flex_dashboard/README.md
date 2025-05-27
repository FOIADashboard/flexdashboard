# FOIA Annual Report Dashboard

This repository contains the code and data
for the [FOIA Annual Report Dashboard](https://deportationresearch.shinyapps.io/FOIAdashboard/).

## Data

### RDS File

The dashboard uses data processed by the [FOIA data mining script](https://github.com/rcds-dssv/foia_data_mining).
This script mines and process a collection of XLM files for
a particular agency and converts to an `.rds` file. The file name
follows the format `{agency}_data.rds`. The `{agency}` part should match exactly
what's being used in the dashboard. For example, if the agency is `DHS`, the file
name should be `DHS_data.rds`.
More detail on using the script to process the data is available in the
`instructions.md` file of the data mining repository.

Once the data is processed, move the `.rds` file to the `data/rds` directory.
You should see that some data is already there. If you are updating an agency,
replace the old file with the new one.

### CSV File

The budget data can be optionally included for each agency as a CSV file. 
This file is used to display statistics in the `Budget` tab of the dashboard.

The file name should follow the same convention: `{agency}_budget_ratio.csv`.
The origin of these files are uncertainty, but Jackie's lab members should be
able to track and provide them.

For the visualization in the `Budget` tabe to display correctly, the CSV file
should contain (at least) the following columns:

`Year`, `{component}_budget`, `{component}_ratio`, `{component}_backlog`

Where `{component}` is the name of the component of the agency. 
For example, if `DHS` has components `ICE` and `CBP`, the CSV file should
contain at least

`Year`, `ICE_budget`, `ICE_ratio`, `ICE_backlog`, `CBP_budget`, 
`CBP_ratio`, `CBP_backlog`

The RDS files and CSV files work independently, so not all agencies need to be
present in both formats.

## Dashboard

Code for the dashboard is in the `FOIA_flexdashboard.Rmd` file.

The dashboard has three tabs: `FOIA METRICS`, `BUDGETS`, `ABOUT`. The `FOIA METRICS`
tab uses the RDS files to display annual FOIA statistics for each agency. Here
users can choose which section (data) to display, agency and components of interest,
and years of interest. The `BUDGETS` tab uses the CSV files to display budget
information for each agency. Similarly the users can choose agency and a component.
The `ABOUT` tab contains information about the dashboard.

### Configuration

General configuration of the dashboard is managed in the `global` code chunk 
(the first chunk in the dashboard). Think chunk loads necessary packages, 
sources helper scripts, defines agencies, components, sections, 
and custom plot titles. Following are some important variables you may interact
with often:

- `agencies`: agencies to be displayed in the `FOIA METRICS` tab
- `agencies_budget`: agencies to be displayed in the `BUDGETS` tab
- `components`: list components for each agency
- `section_choices`: available sections for each agency in the `FOIA METRICS` tab
- `variable_choice_list`: how the variables in each sections should be displayed in the dropdown menu
- `manual_title_list`: how the variable should be displayed in the plot title

### Update Process

Once new agency data is added to the `data/rds` or `data/csv` directory, 
the dashboard should be updated to reflect the new data.
This is done by updating the `agencies` and
`agencies_budget` variables in the `global` code chunk. The new agency should be

### Publishing App

## Version Control

