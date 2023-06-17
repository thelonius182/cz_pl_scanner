# init ----
delta_min_allowed <- -0.17 # audio mag tot ca. 10 seconden te kort zijn
delta_plus_allowed <- 2.5 # mag tot 2,5 minuut te lang zijn (vanwege hijack cue's)

# hier staan de apple-script dumps
ipls_dir_info_uzm <- dir_info(path = "//uitzendmac-2/macOS/Users/tech_1/Documents/Salsa/IPS-output") 
ipls_dir_info_lgm <- dir_info(path = "//logmac/tech/Documents/Salsa/IPS-output") 

# namen vd actuele dumps  ----
ipls_file_uzm <- ipls_dir_info_uzm %>% 
  filter(change_time == max(ipls_dir_info_uzm$change_time)) %>% 
  select(path)

ipls_file_lgm <- ipls_dir_info_lgm %>% 
  filter(change_time == max(ipls_dir_info_lgm$change_time)) %>% 
  select(path)

# import dumps ----
ipls_info_uzm.I <- read_delim(file = as.character(ipls_file_uzm),
                            delim = "\t",
                            escape_double = FALSE,
                            trim_ws = TRUE,
                            show_col_types = FALSE) %>% 
  # utf-8 van legacy mac-OS flat text wordt niet altijd goed herkend
  mutate(`Playlist name` = str_replace(`Playlist name`, "Ori.*press", "Oriënt Express"))

ipls_info_lgm.I <- read_delim(file = as.character(ipls_file_lgm),
                            delim = "\t",
                            escape_double = FALSE,
                            trim_ws = TRUE,
                            show_col_types = FALSE)

# filter relevante kenmerken ----
ipls_info_uzm.II <- ipls_info_uzm.I %>% 
  filter(Folder == "\'R4.0"
         & Remark != "no iVolume adjustment"
         & Aspect != "PL-signature"
         & Remark != "album tag missing")

ipls_info_lgm.II <- ipls_info_lgm.I %>% 
  filter(Folder == "\'R4.0"
         & Remark != "no iVolume adjustment"
         & Aspect != "PL-signature"
         & Remark != "album tag missing")

# zet log/uzm op 1 lijst ----
# dwz alle playlists, niet alleen die van de huidige week
ipls_info_all <- rbind(ipls_info_uzm.II, ipls_info_lgm.II) %>% 
  select(playlist = `Playlist name`, Aspect, Remark) %>% 
  arrange(playlist)

# lees brondata weekschema ----
# (zoals ze deze week op de pdf staan die gebruikt wordt om de playlists te vullen)
# NB - wordt klaargezet door RL-schedulecompiler
ipls_weekschema.I <- readRDS(file = "/cz_salsa/cz_exchange/cur_cz_week_uzm.RDS")

ipls_weekschema <- ipls_weekschema.I %>% 
  filter(str_length(mac) > 0) %>% 
  mutate(playlist = paste0(mac, " - ", sched_playlist),
         playtime_verwacht = as.numeric(cz_slot_len)) %>% 
  select(playlist, playtime_verwacht)

# ipls_info uitdunnen ----
# alleen playlists huidige week 
ipls_info <- ipls_info_all %>% 
  filter(playlist %in% ipls_weekschema$playlist)

# bepaal klaargezette lengtes ----
ipls_playtime <- ipls_info %>% 
  filter(Aspect == "total running time (minutes)") %>% 
  mutate(playtime_aangetroffen = as.numeric(str_replace(Remark, ",", "."))) %>% 
  select(starts_with("play"))

# rapporteer afwijkingen ----
#+ lengtes ----

ipls_length_check <- 
  ipls_weekschema %>% left_join(ipls_playtime) %>%
  mutate(delta_in_minuten = playtime_aangetroffen - playtime_verwacht) %>% distinct() %>% 
  filter(delta_in_minuten > 0 & delta_in_minuten >= delta_plus_allowed
         | delta_in_minuten < 0 & delta_in_minuten <= delta_min_allowed)

n_length_checks <- ipls_length_check %>% nrow()
ipls_notification <- ""

if (n_length_checks > 0) {
  
  for (n1 in 1:n_length_checks) {
    ipls_notification <-
      paste0(ipls_notification,
             "\nplaylist = ",
             ipls_length_check$playlist[n1],
             ", verwacht: ",
             round(ipls_length_check$playtime_verwacht[n1], 2),
             ", aangetroffen: ",
             round(ipls_length_check$playtime_aangetroffen[n1], 2),
             ", verschil: ",
             round(ipls_length_check$delta_in_minuten[n1], 2),
             " minuten"
      )
  }
  
  flog.info("2. Playlist-lengte wijkt af.", name = "ipls_log")
  flog.info(ipls_notification, name = "ipls_log")
  
} else {
  flog.info("2. Playlist-lengtes zijn in orde.", name = "ipls_log")
}

#+ locaties ----
ipls_invalid_drive <- ipls_info %>% 
  filter(Remark == "invalid drive") %>% 
  select(playlist, track = Aspect, problem = Remark)

n_ipls_invalid_drive <- ipls_invalid_drive %>% nrow()
ipls_notification <- ""

if (n_ipls_invalid_drive > 0) {
  
  for (n1 in 1:n_ipls_invalid_drive) {
    ipls_notification <-
      paste0(ipls_notification,
             "\nplaylist = ",
             ipls_invalid_drive$playlist[n1],
             ", ",
             ipls_invalid_drive$track[n1]
      )
  }
  
  flog.info("3. Audio staat op een dubieuze locatie.", name = "ipls_log")
  flog.info(ipls_notification, name = "ipls_log")
  
} else {
  flog.info("3. Audiolocaties zijn in orde.", name = "ipls_log")
}

#+ dead tracks ----
ipls_dead_track <- ipls_info %>% 
  filter(Remark == "dead track") %>% 
  select(playlist, track = Aspect, problem = Remark)

n_ipls_dead_track <- ipls_dead_track %>% nrow()
ipls_notification <- ""

if (n_ipls_dead_track > 0) {
  
  for (n1 in 1:n_ipls_dead_track) {
    ipls_notification <-
      paste0(ipls_notification,
             "\nplaylist = ",
             ipls_dead_track$playlist[n1],
             ", ",
             ipls_dead_track$track[n1]
      )
  }
  
  flog.info("4. Er zijn dead tracks.", name = "ipls_log")
  flog.info(ipls_notification, name = "ipls_log")
  
} else {
  flog.info("4. Geen dead tracks aangetroffen.", name = "ipls_log")
}
