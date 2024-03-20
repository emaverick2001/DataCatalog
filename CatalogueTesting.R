### TESTING CATALOGUE FUNCTION (FOR ALL STUDIES) ###


### TESTING CATALOGUE.STUDY FUNCTION ###
library(tidyverse)
# source('/Users/shilber1/Desktop/Hopkins Coding/CPCR-Repository/codebase/extra/HarmonizedDataFunctions.R')
source('/Users/maver/Documents/CPCR/CPCR-Repository/codebase/extra/HarmonizedDataFunctions.R')
# setwd('/Users/shilber1/Desktop/Hopkins Coding/Data Catalogue/Tests')
setwd('/Users/maver/Documents/CPCR/Data Harmonization Search Engine/')

# Lyme
lyme_scores <- read.csv('/Users/shilber1/Documents/DataManagement/OnlineData/QualtricsData/Study-Data/LymePsilocybinStudy/ScoredData/2203_LymePsilocybin_AllScoredData.csv')

lyme_catalogue <- catalogue.study(lyme_scores)

# MDD/AUD
mddaud_scores <- read.csv('/Users/shilber1/Documents/DataManagement/OnlineData/QualtricsData/Study-Data/MDD-AUD/ScoredData/2004_OutcomeDataAndScores.csv', check.names = F)

mddaud_catalogue <- catalogue.study(mddaud_scores)

# ALZ
alz_pt <- read.csv('/Users/shilber1/Documents/DataManagement/OnlineData/QualtricsData/Study-Data/Alzheimers/ScoredData/1903_AllScoredData_Participant.csv')
alz_co <- read.csv('/Users/shilber1/Documents/DataManagement/OnlineData/QualtricsData/Study-Data/Alzheimers/ScoredData/1903_AllScoredData_CommunityObserver.csv')

alz_pt_catalogue <- catalogue.study(alz_pt)

al_co_catalogue <- catalogue.study(alz_co)

# Healthy Vol/EEG
eeg <- read.csv('2104_AllScoredData (1).csv', check.names = F)

eeg_catalogue <- catalogue.study(eeg)

### TESTING GENERAL CATALOGUE FUNCTION #######

studies <- list("Lyme" = lyme_catalogue,"EEG" = eeg_catalogue,"ALZ" = alz_pt_catalogue,"MDD/AUD" = mddaud_catalogue)
gen_catalogue <- catalogue(studies)







# Have study df with prefix, num items, subscales
## Need unique list of prefix, and join w num item and subscales to ensure getting same num items and subscale values across studies per prefix

## Then for the study column, check X if any X found in that row within that df for that measure


# study_catalogues <- unname(studies)
# study_names <- names(studies)
# 
# study_catalogues_info <- lapply(study_catalogues, function(df) select(df, Prefix, `Number of Items`, Subscales))
# 
# gen_catalogue <- reduce(study_catalogues_info, full_join, by = c("Prefix", "Number of Items", "Subscales")) # Combining information about each measure from each study catalogue
#   # for each study in list, add column to gen_catalogue and check X in the row if matching a row from those columns in the df
# study_columns <- lapply(studies, function(study) {
#   ifelse(paste(gen_catalogue$Prefix, gen_catalogue$`Number of Items`, gen_catalogue$Subscales) %in% 
#                  paste(study$Prefix, study$`Number of Items`, study$Subscales), "X", NA)
# })
# 
# gen_catalogue <- cbind(gen_catalogue, study_columns)

#write.csv(gen_catalogue, 'CPCR_GeneralCatalogue.csv')
