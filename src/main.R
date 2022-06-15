# = = = = = = = = =
# Check vulling van de wekelijkse playlists
# = = = = = = = = =

# - - - - - - - - -
# Init
# - - - - - - - - -
suppressWarnings(library(tidyr))
# library(knitr)
# library(rmarkdown)
# library(googlesheets)
# library(RCurl)
suppressWarnings(suppressPackageStartupMessages(library(yaml)))
suppressWarnings(suppressPackageStartupMessages(library(magrittr)))
suppressWarnings(suppressPackageStartupMessages(library(stringr)))
suppressWarnings(suppressPackageStartupMessages(library(dplyr)))
suppressWarnings(suppressPackageStartupMessages(library(purrr)))
suppressWarnings(suppressPackageStartupMessages(library(lubridate)))
suppressWarnings(suppressPackageStartupMessages(library(fs)))
suppressWarnings(suppressPackageStartupMessages(library(readr)))
suppressWarnings(suppressPackageStartupMessages(library(futile.logger)))
# library(keyring)
# library(RMySQL)
# library(officer)

filter <- dplyr::filter # voorkom verwarring met stats::filter

fa <- flog.appender(appender.file("/Users/scanner/Logs/ipl_scanner.log"), name = "ipls_log")
flog.info("= = = = = iTunes Playlist Scanner start = = = = =", name = "ipls_log")

config <- read_yaml("config.yaml")

uzm_path <- "//UITZENDMAC-2/macOS/Users/tech_1/Music/Radiologik/Schedule"
log_path <- "//LOGMAC/Radiologik/Schedule"

# is RL compleet? ----
source("src/check_for_holes.R", encoding = "UTF-8")
# issues met playlists? ----
source("src/stage_host_reports.R", encoding = "UTF-8")

flog.info("= = = = = iTunes Playlist Scanner stop  = = = = =", name = "ipls_log")
