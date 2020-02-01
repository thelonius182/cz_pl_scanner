# = = = = = = = = =
# Check vulling van de wekelijkse playlists
# = = = = = = = = =

# - - - - - - - - -
# Init
# - - - - - - - - -
library(tidyr)
library(knitr)
library(rmarkdown)
library(googlesheets)
library(RCurl)
library(yaml)
library(magrittr)
library(stringr)
library(dplyr)
library(purrr)
library(lubridate)
library(fs)
library(readr)
library(futile.logger)
library(keyring)
library(RMySQL)
library(officer)

filter <- dplyr::filter # voorkom verwarring met stats::filter

flog.appender(appender.file("/Users/scanner/Logs/ipl_scanner.log"), name = "ipls_log")
flog.info("= = = = = iTunes Playlist Scanner start = = = = =", name = "ipls_log", encoding = "UTF-8")

config <- read_yaml("config.yaml")

uzm_path <- "//UITZENDMAC-CZ/Radiologik/Schedule"
log_path <- "//LOGMAC/Radiologik/Schedule"

# is RL compleet? ----
source("src/check_for_holes.R", encoding = "UTF-8")
# issues met playlists? ----
source("src/stage_host_reports.R", encoding = "UTF-8")

flog.info("= = = = = iTunes Playlist Scanner stop  = = = = =", name = "ipls_log")
