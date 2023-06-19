import os
import pandas as pd
import random
import glob

from time import *
from datetime import *

# GAMERS MANIFEST
def update_gamer_manifest():
    gamer_achievement_names = [filename for filename in os.listdir("./data/gamer/achievements/") if filename.endswith("_achievements.csv")]
    gamer_games_names = [filename for filename in os.listdir("./data/gamer/games/") if filename.endswith("_games.csv")]

    gamer_names = list(set([name.split("_")[0] for name in gamer_achievement_names] + [name.split("_")[0] for name in gamer_games_names]))

    leaderboard_data = pd.read_csv("./data/leaderboard/leaderboard.csv")
    link_data = leaderboard_data[leaderboard_data["GamerTag"].isin(gamer_names)][["GamerTag", "Link"]]

    manifest_file = "./data/manifest/gamer_manifest.csv"
    if os.path.exists(manifest_file):
        existing_manifest = pd.read_csv(manifest_file)
        existing_manifest = existing_manifest[["GamerTag", "Achievements Last Scraped", "Games Last Scraped", "Location Last Scraped", "LocationSrc", "LocationAlt", "LocationTitle"]]
        data = {
            "GamerTag": gamer_names,
            "Achievements File": ["Yes" if any(name.startswith(tag) for name in gamer_achievement_names) else "No" for tag in gamer_names],
            "Games File": ["Yes" if any(name.startswith(tag) for name in gamer_games_names) else "No" for tag in gamer_names],
            "Link": [link_data[link_data["GamerTag"] == name]["Link"].values[0] if name in link_data["GamerTag"].values else "" for name in gamer_names]
        }
        df = pd.DataFrame(data)
        merged_manifest = pd.merge(df, existing_manifest, on="GamerTag", how="left")
        merged_manifest.to_csv(manifest_file, index=False)
    else:
        data = {
            "GamerTag": gamer_names,
            "Achievements File": ["Yes" if any(name.startswith(tag) for name in gamer_achievement_names) else "No" for tag in gamer_names],
            "Games File": ["Yes" if any(name.startswith(tag) for name in gamer_games_names) else "No" for tag in gamer_names],
            "Achievements Last Scraped": ["N/A" for _ in gamer_names],
            "Games Last Scraped": ["N/A" for _ in gamer_names],
            "Location Last Scraped": ["N/A" for _ in gamer_names],
            "LocationSrc": ["N/A" for _ in gamer_names],
            "LocationAlt": ["N/A" for _ in gamer_names],
            "LocationTitle": ["N/A" for _ in gamer_names],
            "Link": [link_data[link_data["GamerTag"] == name]["Link"].values[0] if name in link_data["GamerTag"].values else "" for name in gamer_names]
        }
        df = pd.DataFrame(data)
        df.to_csv(manifest_file, index=False)

    print("Gamer manifest updated.")

def return_incomplete_gamers_manifest(selection="everything"):
    manifest_file = "./data/manifest/gamer_manifest.csv"

    if not os.path.exists(manifest_file):
        print("Gamer manifest does not exist.")
        return

    df = pd.read_csv(manifest_file)

    if selection == "achievements":
        incomplete_profiles = df[(df["Achievements File"] != "Yes") | pd.isnull(df["Achievements Last Scraped"]) | (df["Achievements Last Scraped"].astype(str).str.strip() == "")]
    elif selection == "games":
        incomplete_profiles = df[(df["Games File"] != "Yes") | pd.isnull(df["Games Last Scraped"]) | (df["Games Last Scraped"].astype(str).str.strip() == "")]
    else:  # Select everything
        incomplete_profiles = df[((df["Achievements File"] != "Yes") | pd.isnull(df["Achievements Last Scraped"]) | (df["Achievements Last Scraped"].astype(str).str.strip() == "")) |
                                 ((df["Games File"] != "Yes") | pd.isnull(df["Games Last Scraped"]) | (df["Games Last Scraped"].astype(str).str.strip() == ""))]

    if len(incomplete_profiles) > 0:
        return incomplete_profiles
    else:
        print("All profiles have achievements, games, and metrics files.")



def check_duplicates_profile(gamertag, metric_type="achievements"):
    # Read the CSV file into a DataFrame
    dup_df = pd.read_csv(f'./data/gamer/{metric_type}/{gamertag}_{metric_type}.csv')
    duplicates = dup_df.duplicated()

    # Print the duplicate rows
    print(f"DUPLICATES FOR {gamertag} ({metric_type}): {len(dup_df[duplicates])}")

def check_duplicates_all_profiles(directory, metric_type="achievements"):
    # Get a list of all files in the directory
    files = os.listdir(directory)
    
    for file in files:
        # Extract the gamertag from the file name
        gamertag = os.path.splitext(file)[0]
        
        # Read the CSV file into a DataFrame
        file_path = os.path.join(directory, file)
        dup_df = pd.read_csv(file_path)
        
        # Check for duplicates
        duplicates = dup_df.duplicated()
        
        # Print the duplicate rows
        print(f"DUPLICATES FOR {gamertag} ({metric_type}): {len(dup_df[duplicates])}")





##################### WIP WIP WIP
# ACHIEVEMENTS MANIFEST
def read_random_gamers(num_files, suffix):
    # Get file paths for gamer profiles with "_achievements.csv" at the end
    file_paths = glob.glob(f"./data/gamer/achievements/*{suffix}")
    
    # Get random indices
    random_indices = random.sample(range(len(file_paths)), num_files)
    
    # Initialize list to store DataFrames
    df_list = []

    # Read and store the selected files
    for i in random_indices:
        file_path = file_paths[i]
        df = pd.read_csv(file_path)
        df_list.append(df)
    
    # Return the list of DataFrames
    return df_list

def update_achievement_manifest(dfs):
    manifest_file = "./data/manifest/achievements_manifest.csv"
    df = pd.concat(dfs, ignore_index=True)

    # Remove unwanted parts from achievement_game_url and achievement_url
    df["achievement_game_url"] = df["achievement_game_url"].str.replace(r'achievements\?.*', '', regex=True)
    df["achievement_url"] = df["achievement_url"].str.replace(r'#\d+', '', regex=True)

    if os.path.exists(manifest_file):
        existing_manifest = pd.read_csv(manifest_file)
        combined_achievements = pd.concat([existing_manifest, df], ignore_index=True)
    else:
        combined_achievements = df
    unique_achievements = combined_achievements.drop_duplicates()
    unique_achievements = unique_achievements.drop(columns=["achievement_earned"])
    unique_achievements.to_csv(manifest_file, index=False)


# GAMES MANIFEST

