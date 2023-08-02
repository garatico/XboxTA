import os
import pandas as pd

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


