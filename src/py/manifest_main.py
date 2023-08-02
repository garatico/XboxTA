import os
import pandas as pd
import random
import glob

from time import *
from datetime import *

from src.py.manifest.gamer_manifest import *

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

