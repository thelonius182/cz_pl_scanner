detect_holes <- function(cz_dir_path) {
  # T E S T !!
  cz_dir_path = uzm_path
  # T E S T !!
  
  # Ochtendeditie-scripts
  # bv 005 - 2020-01-30_do07-180_ochtendeditie
  #    ^
  #    37
  sched.I <- dir_info(path = cz_dir_path) %>% 
    filter(str_detect(path, "ochtendeditie")) %>% 
    mutate(script_item = str_sub(path, 37, 39),
           script_date = str_sub(path, 43, 52),
           script_hour = str_sub(path, 56, 57),
           script_length = str_sub(path, 59, 61)
    ) %>% 
    select(starts_with("script"), -script_item)
  
  # Overige scripts
  script_rgx <- ".*Schedule/[0-9]{3} - ([0-9]{4}-[0-9]{2}-[0-9]{2})_\\w{2}([0-9]{2})_([0-9]{3}).*"
  
  sched.II <- dir_info(path = cz_dir_path) %>% 
    rename(dir_info_path = path) %>% 
    filter(!str_detect(dir_info_path, "ochtendeditie")) %>%
    filter(str_detect(dir_info_path, "^.*? - [0-9]{4}-.*")) %>%
    mutate(script_date = sub(script_rgx, "\\1", dir_info_path, perl=TRUE),
           script_hour = sub(script_rgx, "\\2", dir_info_path, perl=TRUE),
           script_length = sub(script_rgx, "\\3", dir_info_path, perl=TRUE)) %>% 
    select(starts_with("script"))
  

  return(czweek_files_to_ditch)
}
