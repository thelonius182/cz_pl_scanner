suppressWarnings(suppressPackageStartupMessages(library(magrittr)))
suppressWarnings(suppressPackageStartupMessages(library(tidyr)))
suppressWarnings(suppressPackageStartupMessages(library(dplyr)))
suppressWarnings(suppressPackageStartupMessages(library(stringr)))
suppressWarnings(suppressPackageStartupMessages(library(readr)))
suppressWarnings(suppressPackageStartupMessages(library(lubridate)))
suppressWarnings(suppressPackageStartupMessages(library(fs)))
suppressWarnings(suppressPackageStartupMessages(library(futile.logger)))
suppressWarnings(suppressPackageStartupMessages(library(jsonlite)))
suppressWarnings(suppressPackageStartupMessages(library(httr)))
suppressWarnings(suppressPackageStartupMessages(library(ssh)))

gh_sess <- ssh_connect("cz@streams.greenhost.nl")

gh_cmd <- paste0("ls /var/log/", "icecast2", " -lt --time-style=+'%Y-%m-%d %H:%M:%S' | grep access.log | grep gz")

gh_logs <- ssh_exec_internal(session = gh_sess, gh_cmd) %>%
  .[["stdout"]] %>%
  rawToChar() %>%
  strsplit("\n") %>%
  unlist() %>%
  as_tibble()

ssh_disconnect(session = gh_sess)
