import pandas as pd

from src.py.scrape.scrape_gamer_achievements import *
from src.py.scrape.scrape_gamer_games import *

##### GAMER SCRAPE MULTIPLE #####
def scrape_multiple_gamers_data(gamers, data_type):
    data = []

    for index, gamer in gamers.iterrows():
        url = gamer['Link']
        gamertag = gamer['GamerTag']
        sleep(randint(5, 10))
        # Scrape data based on the specified type
        print(f"GAMER: {gamertag} INITIALIZE ({data_type.upper()})")
        if data_type == "achievements":
            profile_data = scrape_gamer_achievements(url)
        elif data_type == "games":
            profile_data = scrape_gamer_games(url)
        else:
            print(f"Invalid data type: {data_type}")
            continue

        if profile_data:
            profile_df = pd.DataFrame(profile_data)
            profile_df.to_csv(f'./data/gamer/{data_type}/{gamertag}_{data_type}.csv', index=False)
        else:
            print(f"No {data_type} data found for {gamertag}")
    return data

def scrape_random_gamers_data(sample_size=1, data_type="achievements"):
    lb_df = pd.read_csv('./data/leaderboard/leaderboard.csv')
    # Shuffle the rows of the leaderboard dataframe
    sample_df = lb_df.sample(n=sample_size)

    if data_type == "achievements":
        scrape_multiple_gamers_data(sample_df, data_type="achievements")
    elif data_type == "games":
        scrape_multiple_gamers_data(sample_df, data_type="games")
    else:
        print(f"Invalid data type: {data_type}")






