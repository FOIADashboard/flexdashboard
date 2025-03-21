# following script checks that all necessary columns are present in the data files

library(tidyverse)

dhs <- readRDS("data/rds/DHS_data.rds")
dol <- readRDS("data/rds/DOL_data.rds")
doj <- readRDS("data/rds/DOJ_data.rds")
dos <- readRDS("data/rds/DOS_data.rds")
hhs <- readRDS("data/rds/HHS_data.rds")
epa <- readRDS("data/rds/EPA_data.rds")

agency_data <- list(dhs = dhs, dol = dol, doj = doj, dos = dos, hhs = hhs, epa = epa)

check_colnames_exist <- function(agency_data, section_name, data_colnames) {
  agency_data %>% 
    map(~ all(data_colnames %in% colnames(.x[[section_name]])))
}

# Personnel/Cost

section_name <- "PersonnelAndCostSection"

data_colnames <- c(
  "FullTimeEmployeeQuantity",  "EquivalentFullTimeEmployeeQuantity",
  "TotalFullTimeStaffQuantity",  "ProcessingCostAmount",
  "LitigationCostAmount",  "TotalCostAmount"
)

check_colnames_exist(agency_data, section_name, data_colnames)

# Backlog

section_name <- "BacklogSection"

data_colnames <- c(
  "BackloggedRequestQuantity"
)

check_colnames_exist(agency_data, section_name, data_colnames)

# Expediated Processing

section_name <- "ExpeditedProcessingSection"

data_colnames <- c(
  "RequestGrantedQuantity",
  "RequestDeniedQuantity",
  "AdjudicationMedianDaysValue",
  "AdjudicationAverageDaysValue",
  "AdjudicationWithinTenDaysQuantity"
)

check_colnames_exist(agency_data, section_name, data_colnames)

# Processed Requests

section_name <- "ProcessedRequestSection"

data_colnames <- c(
  "ProcessingStatisticsPendingAtStartQuantity",
  "ProcessingStatisticsPendingAtEndQuantity",
  "ProcessingStatisticsReceivedQuantity",
  "ProcessingStatisticsProcessedQuantity"
)

check_colnames_exist(agency_data, section_name, data_colnames)

# Pending Requests

section_name <- "PendingPerfectedRequestsSection"

data_colnames <- c(
  "SimplePendingRequestStatistics_PendingRequestQuantity",
  "SimplePendingRequestStatistics_PendingRequestMedianDaysValue",
  "SimplePendingRequestStatistics_PendingRequestAverageDaysValue",
  "ComplexPendingRequestStatistics_PendingRequestQuantity",
  "ComplexPendingRequestStatistics_PendingRequestMedianDaysValue",
  "ComplexPendingRequestStatistics_PendingRequestAverageDaysValue",
  "ExpeditedPendingRequestStatistics_PendingRequestQuantity",
  "ExpeditedPendingRequestStatistics_PendingRequestMedianDaysValue",
  "ExpeditedPendingRequestStatistics_PendingRequestAverageDaysValue"
)

check_colnames_exist(agency_data, section_name, data_colnames)

# Pending Requests

section_name <- "AppealDispositionSection"

data_colnames <- c(
  "AppealDispositionAffirmedQuantity",
  "AppealDispositionPartialQuantity",
  "AppealDispositionReversedQuantity",
  "AppealDispositionOtherQuantity",
  "AppealDispositionTotalQuantity"
)

check_colnames_exist(agency_data, section_name, data_colnames)

