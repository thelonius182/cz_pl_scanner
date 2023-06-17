# Check vulling van de wekelijkse playlists

pacman::p_load(tidyr, yaml, magrittr, stringr, purrr, lubridate, fs, readr, futile.logger, dplyr)

fa <- flog.appender(appender.file("/Users/scanner/Logs/ipl_scanner.log"), name = "ipls_log")
flog.info("= = = = = iTunes Playlist Scanner start = = = = =", name = "ipls_log")

config <- read_yaml("config.yaml")

uzm_path <- "//UITZENDMAC-2/macOS/Users/tech_1/Music/Radiologik/Schedule"
log_path <- "//LOGMAC/tech/Music/Radiologik/Schedule"

# is RL compleet? ----
source("src/check_for_holes.R", encoding = "UTF-8")
# issues met playlists? ----
source("src/stage_host_reports.R", encoding = "UTF-8")

flog.info("= = = = = iTunes Playlist Scanner stop  = = = = =", name = "ipls_log")
