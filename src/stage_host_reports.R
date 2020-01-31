iTunes_Playlist_Scanner_UitzendMac <-
  read_delim(
    "//uitzendmac-cz/tech/Documents/Salsa/IPS-output/iTunes Playlist Scanner (UitzendMac), 30-01-20.txt",
    "\t",
    escape_double = FALSE,
    trim_ws = TRUE
  )

host1 <- iTunes_Playlist_Scanner_UitzendMac %>% 
  filter(Folder == '\'R4.0' 
         & Remark != 'no iVolume adjustment'
         & Remark != 'album tag missing')

plws <- readRDS(file = "g://salsa//plws.RDS")
