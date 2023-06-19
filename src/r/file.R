sample_random_gamers <- function(num_files, directory_df) {
  # Get random indices
  random_indices <- sample(1:nrow(directory_df), num_files)
  
  # Initialize lists to store data frames and gamertags
  achievements_list <- list()
  games_list <- list()
  gamertags <- character(num_files)
  
  # Read and store the selected files
  count <- 0
  for (i in 1:num_files) {
    # Read achievements.csv
    achievement_file_path <- directory_df$achievements_directory[random_indices[i]]
    games_file_path <- directory_df$games_directory[random_indices[i]]
    
    if (file.exists(achievement_file_path) && file.exists(games_file_path)) {
      achievement_df <- read.csv(achievement_file_path)
      games_df <- read.csv(games_file_path)
      
      if (nrow(achievement_df) > 0 && nrow(games_df) > 0) {
        count <- count + 1
        achievements_list[[count]] <- achievement_df
        games_list[[count]] <- games_df
        gamertags[count] <- directory_df$gamertag[random_indices[i]]
      }
    }
  }
  
  # Trim the lists to match the number of complete entries
  achievements_list <- achievements_list[1:count]
  games_list <- games_list[1:count]
  gamertags <- gamertags[1:count]
  
  # Return the list of lists with gamertags
  return(list(achievements = achievements_list, games = games_list, gamertags = gamertags))
}

create_file_directory = function() {
  achievements_csvs = list.files("./data/gamer/achievements/",
                                 pattern = "_achievements.csv",
                                 full.names = TRUE)
  games_csvs = list.files("./data/gamer/games/",
                          pattern = "_games.csv",
                          full.names = TRUE)
  
  achievement_gamertags = sub("_achievements.csv", "", basename(achievements_csvs))
  games_gamertags = sub("_games.csv", "", basename(games_csvs))
  
  achievement_directory_df = data.frame(achievements_directory = achievements_csvs,
                                        gamertag = achievement_gamertags,
                                        stringsAsFactors = FALSE)
  games_directory_df = data.frame(games_directory = games_csvs,
                                  gamertag = games_gamertags,
                                  stringsAsFactors = FALSE)
  
  directory_df = merge(achievement_directory_df, games_directory_df, by = "gamertag", all = TRUE)
  
  # Read gamer_manifest.csv
  gamer_manifest = read.csv("./data/manifest/gamer_manifest.csv")
  
  # Merge directory_df with gamer_manifest based on gamertag/GamerTag
  directory_df = merge(directory_df, gamer_manifest, by.x = "gamertag", by.y = "GamerTag", all = TRUE)
  return(directory_df)
}


