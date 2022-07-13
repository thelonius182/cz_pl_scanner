# verzamel scripts op FS ----
# om te kijken of de reeks compleet is

#+ OE ---- 
# bv //UITZENDMAC-2/macOS/Users/tech_1/Music/Radiologik/Schedule/021 - 2022-06-22_wo07-180_ochtendeditie
#    ^
#    37
sched.I <- dir_info(path = uzm_path) %>%
  filter(str_detect(path, "ochtendeditie")) %>%
  mutate(
    script_item = sub(".*?/Schedule/\\b(\\d{3})\\b.*", "\\1", path, perl=TRUE, ignore.case=TRUE),
    script_date = sub(".*?/Schedule/.*(\\d{4}-\\d{2}-\\d{2}).*", "\\1", path, perl=TRUE, ignore.case=TRUE),
    script_hour = sub(".*?/Schedule/.*_\\w{2}(\\d{2}).*", "\\1", path, perl=TRUE, ignore.case=TRUE),
    script_length = sub(".*?/Schedule/.*\\w{2}\\d{2}-(\\d{3}).*", "\\1", path, perl=TRUE, ignore.case=TRUE)
  ) %>%
  select(starts_with("script"),-script_item)

sched.Ia <- sched.I %>%
  mutate(
    slot_start = ymd_hms(paste0(script_date, " ", script_hour, ":00:00")),
    slot_stop = slot_start + minutes(as.integer(script_length)),
    slot_name = "Ochtendeditie"
  ) %>%
  select(starts_with("slot"))

#+ overige UZM ----
script_rgx <-
  ".*Schedule/[0-9]{3} - ([0-9]{4}-[0-9]{2}-[0-9]{2})_\\w{2}([0-9]{2})_([0-9]{3}).*"

sched.II <- dir_info(path = uzm_path) %>%
  rename(dir_info_path = path) %>%
  filter(!str_detect(dir_info_path, "ochtendeditie")) %>%
  filter(str_detect(dir_info_path, "^.*? - [0-9]{4}-.*")) %>%
  mutate(
    script_date = sub(script_rgx, "\\1", dir_info_path, perl = TRUE),
    script_hour = sub(script_rgx, "\\2", dir_info_path, perl = TRUE),
    script_length = sub(script_rgx, "\\3", dir_info_path, perl =
                          TRUE)
  ) %>%
  select(starts_with("script"), dir_info_path) %>% 
  filter(!str_starts(script_date, "//"))

sched.IIa <- sched.II %>%
  mutate(
    slot_start = ymd_hms(paste0(script_date, " ", script_hour, ":00:00")),
    slot_stop = slot_start + minutes(as.integer(script_length)),
    slot_name = str_replace(
      dir_info_path,
      "//UITZENDMAC-2/tech_1/Music/Radiologik/Schedule/\\d{3} - [0-9]{4}-[0-9]{2}-[0-9]{2}_\\w{2}[0-9]{2}_[0-9]{3}_",
      ""
    )
  ) %>%
  select(starts_with("slot"))

#+ overige LGM ----
# //LOGMAC/Radiologik/Schedule/017 - 2020-01-30_do14_120_CZ-Archief
sched.IV <- dir_info(path = log_path) %>%
  mutate(
    script_item = str_sub(path, 41, 43),
    script_date = str_sub(path, 47, 56),
    script_hour = str_sub(path, 60, 61),
    script_length = str_sub(path, 63, 65),
    slot_name = str_replace(
      path,
      "//LOGMAC/tech/Music/Radiologik/Schedule/\\d{3} - [0-9]{4}-[0-9]{2}-[0-9]{2}_\\w{2}[0-9]{2}_[0-9]{3}_",
      ""
    )
  ) %>%
  select(starts_with("script"), slot_name,-script_item) %>%
  filter(str_detect(script_date, "^\\d.*"))

sched.IVa <- sched.IV %>%
  mutate(slot_start = ymd_hms(paste0(script_date, " ", script_hour, ":00:00")),
         slot_stop = slot_start + minutes(as.integer(script_length))) %>%
  select(slot_start, slot_stop, slot_name)

# verzamel live-slots ----
# scripts ontbreken niet als het slot live is
# de rds-file is de recentste die klaargezet is door de RL-schedulecompiler
# NB - alleen live-slots dus data van uzm volstaat; lgm heeft geen live-slots
sched.III <- readRDS(file = "/cz_salsa/cz_exchange/cur_cz_week_uzm.RDS")

sched.IIIa <- sched.III %>%
  filter(sched_playlist == "live > geen playlist nodig") %>%
  mutate(
    slot_start = cz_tijdstip,
    slot_stop = slot_start + minutes(cz_slot_len),
    slot_name = sys_audiotitel
  ) %>%
  select(starts_with("slot"))

# zet alle slots in 1 lijst ----
# alleen die van deze week; begin/eind in sched.III
sched <- rbind(sched.Ia, sched.IIa, sched.IIIa, sched.IVa) %>%
  filter(slot_start >= min(sched.III$cz_tijdstip)
         & slot_start < max(sched.III$cz_tijdstip)) %>%
  arrange(slot_start)

# detecteer ontbrekende scripts ----
gidsgaten <- sched %>%
  mutate(start_next = lead(slot_start)) %>%
  filter(!is.na(start_next) & start_next != slot_stop)

n_gidsgaten <- gidsgaten %>% nrow

#+ rapporteer ----
ipls_notification <- ""

if (n_gidsgaten > 0) {
  
  for (n1 in 1:n_gidsgaten) {
    ipls_notification <-
      paste0(ipls_notification,
             "\n",
             gidsgaten$slot_start[n1],
             ", ",
             gidsgaten$slot_name[n1])
  }
  
  flog.info("1. Er ontbreken RL-scripts na elk van deze slots:", name = "ipls_log")
  flog.info(ipls_notification, name = "ipls_log")
  
} else {
  flog.info("1. RadioLogik is compleet.", name = "ipls_log")
}
