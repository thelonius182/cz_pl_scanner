# Ochtendeditie-scripts
# bv 005 - 2020-01-30_do07-180_ochtendeditie
#    ^
#    37
sched.I <- dir_info(path = uzm_path) %>%
  filter(str_detect(path, "ochtendeditie")) %>%
  mutate(
    script_item = str_sub(path, 37, 39),
    script_date = str_sub(path, 43, 52),
    script_hour = str_sub(path, 56, 57),
    script_length = str_sub(path, 59, 61)
  ) %>%
  select(starts_with("script"),-script_item)

sched.Ia <- sched.I %>%
  mutate(
    slot_start = ymd_hms(paste0(script_date, " ", script_hour, ":00:00")),
    slot_stop = slot_start + minutes(as.integer(script_length)),
    slot_name = "Ochtendeditie"
  ) %>%
  select(starts_with("slot"))

# Overige scripts
script_rgx <-
  ".*Schedule/[0-9]{3} - ([0-9]{4}-[0-9]{2}-[0-9]{2})_\\w{2}([0-9]{2})_([0-9]{3}).*"

sched.II <- dir_info(path = cz_dir_path) %>%
  rename(dir_info_path = path) %>%
  filter(!str_detect(dir_info_path, "ochtendeditie")) %>%
  filter(str_detect(dir_info_path, "^.*? - [0-9]{4}-.*")) %>%
  mutate(
    script_date = sub(script_rgx, "\\1", dir_info_path, perl = TRUE),
    script_hour = sub(script_rgx, "\\2", dir_info_path, perl = TRUE),
    script_length = sub(script_rgx, "\\3", dir_info_path, perl =
                          TRUE)
  ) %>%
  select(starts_with("script"), dir_info_path)

sched.IIa <- sched.II %>%
  mutate(
    slot_start = ymd_hms(paste0(script_date, " ", script_hour, ":00:00")),
    slot_stop = slot_start + minutes(as.integer(script_length)),
    slot_name = str_replace(
      dir_info_path,
      "//UITZENDMAC-CZ/Radiologik/Schedule/\\d{3} - [0-9]{4}-[0-9]{2}-[0-9]{2}_\\w{2}[0-9]{2}_[0-9]{3}_",
      ""
    )
  ) %>%
  select(starts_with("slot"))

# weekoverzicht met live-j/n indicaties
sched.III <- readRDS(file = "g:\\salsa\\cur_cz_week_uzm.RDS")

sched.IIIa <- sched.III %>%
  filter(sched_playlist == "live > geen playlist nodig") %>%
  mutate(
    slot_start = cz_tijdstip,
    slot_stop = slot_start + minutes(cz_slot_len),
    slot_name = sys_audiotitel
  ) %>%
  select(starts_with("slot"))

# Logmac erbij
# //LOGMAC/Radiologik/Schedule/017 - 2020-01-30_do14_120_CZ-Archief
sched.IV <- dir_info(path = log_path) %>%
  mutate(
    script_item = str_sub(path, 30, 32),
    script_date = str_sub(path, 36, 45),
    script_hour = str_sub(path, 49, 50),
    script_length = str_sub(path, 52, 54),
    slot_name = str_replace(
      path,
      "//LOGMAC/Radiologik/Schedule/\\d{3} - [0-9]{4}-[0-9]{2}-[0-9]{2}_\\w{2}[0-9]{2}_[0-9]{3}_",
      ""
    )
  ) %>%
  select(starts_with("script"), slot_name,-script_item) %>%
  filter(str_detect(script_date, "^\\d.*"))

sched.IVa <- sched.IV %>%
  mutate(slot_start = ymd_hms(paste0(script_date, " ", script_hour, ":00:00")),
         slot_stop = slot_start + minutes(as.integer(script_length))) %>%
  select(slot_start, slot_stop, slot_name)

sched <- rbind(sched.Ia, sched.IIa, sched.IIIa, sched.IVa) %>%
  arrange(slot_start)

#+ controleer of er uren in de gids ontbreken ----
gidsgaten <- sched %>%
  filter(slot_start >= min(sched.III$cz_tijdstip) 
         & slot_start <  max(sched.III$cz_tijdstip)) %>% 
  mutate(start_next = lead(slot_start)) %>%
  filter(!is.na(start_next) & start_next != slot_stop)

n_gidsgaten <- gidsgaten %>% nrow
