from time import *
from datetime import *

import pandas as pd

from src.py.manifest_main import return_incomplete_gamers_manifest
from src.py.scrape.scrape_gamer_games import *


def scrape_incomplete_profiles_games():
    incomplete_profiles = return_incomplete_gamers_manifest(selection="games")

    if incomplete_profiles is None:
        print("No incomplete profiles to scrape.")
    else:
        for index, gamer in incomplete_profiles.iterrows():
            gamer_url = f"{gamer['Link']}"

            # Scrape games
            games_data = scrape_gamer_games(gamer_url)
            if games_data:
                games_data = pd.DataFrame(games_data)  # Convert to DataFrame
                games_file = f"./data/gamer/games/{gamer['GamerTag']}_games.csv"
                games_data.to_csv(games_file, index=False)
                now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                manifest_file = "./data/manifest/gamer_manifest.csv"
                manifest_df = pd.read_csv(manifest_file)
                manifest_df.loc[manifest_df['GamerTag'] == gamer['GamerTag'], 'Games Last Scraped'] = now
                manifest_df.to_csv(manifest_file, index=False)
                print(f"Games scraped and saved for {gamer['GamerTag']}.")

    print("Scraping of incomplete profiles (games) completed.")


def rescrape_profiles_games():
    profiles = pd.read_csv("./data/manifest/gamer_manifest.csv")
    for index, gamer in profiles.iterrows():
        gamer_url = f"{gamer['Link']}"
        
        # Scrape games
        games_data = scrape_gamer_games(gamer_url)
        if games_data:
            games_data = pd.DataFrame(games_data)  # Convert to DataFrame
            games_file = f"./data/gamer/games/{gamer['GamerTag']}_games.csv"
            games_data.to_csv(games_file, index=False)
            now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            manifest_file = "./data/manifest/gamer_manifest.csv"
            manifest_df = pd.read_csv(manifest_file)
            manifest_df.loc[manifest_df['GamerTag'] == gamer['GamerTag'], 'Games Last Scraped'] = now
            manifest_df.to_csv(manifest_file, index=False)
            print(f"Games re-scraped and saved for {gamer['GamerTag']}.")

    print("Re-scraping of profiles completed.")
