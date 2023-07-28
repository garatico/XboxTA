import sqlite3

# SQL QUERIES FILES
from leaderboard.leaderboard_queries import *
from leaderboard.directory_queries import *
from gamer_achievements_queries import *

gamer_achievements_directory = get_file_directory('./data/gamer/achievements')
gamer_games_directory = get_file_directory('./data/gamer/games/')

print(gamer_achievements_directory)

#lb_csv = pd.read_csv("./data/leaderboard/leaderboard.csv")
#profile_csv = pd.read_csv("./data/gamer/achievements/PremedGolem786_achievements.csv")

# SQL SETUP LEADERBOARD
lb_conn = sqlite3.connect('./data/sql/leaderboard.db')
#create_lb_tb_if_exists(conn = lb_conn)
#insert_values_into_lb_tb(conn = lb_conn, sample = lb_csv)
insert_values_into_directory_tb(lb_conn, gamer_achievements_directory)
#insert_values_into_directory_tb(lb_conn, gamer_games_directory, "gamer_games_directory")

# SQL SETUP GAMER ACHIEVEMENTS
#gamer_achievement_conn = sqlite3.connect('./data/sql/gamer_achievements.db')
#create_gamer_achievements_tb_if_exists(conn = gamer_achievement_conn, profile = profile_csv)
#gamer_achievement_conn.close()

lb_conn.close()