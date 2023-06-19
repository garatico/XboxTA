from src.py.manifest import *
from src.py.scrape.scrape import *
from src.py.leaderboard import *
from src.py.scrape.rescrape import *

# LEADERBOARD OPERATIONS
#scrape_save_pagerange(startpage = 18200, endpage = 18740, saveafter = 100)
#combine_leaderboard_csv_files()

# GAMERS OPERATIONS
#scrape_random_gamers_data(sample_size=20, data_type="achievements")  # Scrape random gamer achievements
#scrape_random_gamers_data(sample_size=50, data_type="games")  # Scrape random gamer games
#scrape_all_gamer_locations()

# MANIFEST GAMER OPERATIONS
#update_gamer_manifest()

# INCOMPLETE SCRAPES
#scrape_incomplete_profiles_achievements()
#scrape_incomplete_profiles_games()

# RESCRAPES
#rescrape_profiles_achievements()
#rescrape_profiles_games()

# MANIFEST ACHIEVEMENT OPERATIONS
#rnd_achievements = read_random_gamers(150, "_achievements.csv")
#update_achievement_manifest(rnd_achievements)

# CHECK FOR DUPLICATES
#check_duplicates_all_profiles("./data/gamer/achievements/", metric_type="achievements")
#check_duplicates_all_profiles("./data/gamer/games/", metric_type="games")

# DATA SOURCES:
# https://www.trueachievements.com/gamer/PremedGolem786
# https://docs.google.com/spreadsheets/d/1kspw-4paT-eE5-mrCrc4R9tg70lH2ZTFrJOUmOtOytg/edit#gid=0

