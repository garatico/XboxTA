import os
import shutil
import random
import string
import pandas as pd
import re

def generate_random_id(length):
    characters = string.ascii_uppercase + string.digits
    return ''.join(random.choice(characters) for _ in range(length))

def anonymize_filenames_in_directory(nonanon_directory, anon_directory, data_types):
    id_mapping = {}  # Store generated random IDs for each prefix
    
    for data_type in data_types:
        data_type_directory = os.path.join(nonanon_directory, data_type)
        file_list = os.listdir(data_type_directory)
        print(f"Anonymizing {data_type} files...")
        
        if not file_list:
            print(f"No files found in {data_type_directory}.")
        else:
            for file in file_list:
                if f'_{data_type}.csv' in file:
                    prefix, suffix = file.split('_', 1)  # Split at the first '_'
                    
                    if prefix not in id_mapping:
                        random_id = generate_random_id(6)
                        id_mapping[prefix] = random_id
                    else:
                        random_id = id_mapping[prefix]
                    
                    new_filename = f"{random_id}_{data_type}.csv"
                    source_path = os.path.join(data_type_directory, file)
                    target_path = os.path.join(anon_directory, data_type, new_filename)
                    shutil.copy(source_path, target_path)
                    print(f"Copied {file} to {new_filename}")
                else:
                    print(f"File not anonymized: {file}")
    
    return id_mapping

def anonymize_manifest(manifest_path, id_mapping):
    df = pd.read_csv(manifest_path)
    
    # Replace gamertags with their corresponding IDs using id_mapping
    if "GamerTag" in df.columns:
        df["GamerTag"] = df["GamerTag"].map(id_mapping)
    
    # Process URLs and other modifications if needed
    df = remove_gamerid_and_hash_from_urls(df)

    # Drop the "Link" column
    if "Link" in df.columns:
        df = df.drop(columns=["Link"])
    
    # Save the anonymized manifest with IDs
    manifest_dir, manifest_file = os.path.split(manifest_path)
    anonymized_manifest_file = os.path.splitext(manifest_file)[0] + "_anonymous.csv"
    anonymized_manifest_path = os.path.join(manifest_dir, anonymized_manifest_file)
    df.to_csv(anonymized_manifest_path, index=False)
    
    print(f"Anonymized manifest saved as: {anonymized_manifest_path}")


# Subsequent method for further processing the anonymized files
def process_anonymized_filenames(anon_directory, data_types, id_mapping):
    # Example implementation - Print the mapping of original prefixes to random IDs
    for data_type in data_types:
        print(f"Mapping for {data_type}:")
        for prefix, random_id in id_mapping.items():
            print(f"{prefix} -> {random_id}")

def remove_gamerid_and_hash_from_urls(df):
    if "achievement_game_url" in df.columns:
        df["achievement_game_url"] = df["achievement_game_url"].apply(lambda url: re.sub(r'\?gamerid=\d+', '', url))
    if "achievement_url" in df.columns:
        df["achievement_url"] = df["achievement_url"].apply(lambda url: url.split('#', 1)[0])
    if "game_url" in df.columns:
        df["game_url"] = df["game_url"].apply(lambda url: re.sub(r'\?gamerid=\d+', '', url))
    return df

def process_files_in_directory(directory_path):
    file_list = os.listdir(directory_path)
    print("Processing files in directory:")
    
    if not file_list:
        print("No files found in the directory.")
    else:
        for file in file_list:
            file_path = os.path.join(directory_path, file)
            if file.endswith(".csv"):
                df = pd.read_csv(file_path)
                df = remove_gamerid_and_hash_from_urls(df)
                df.to_csv(file_path, index=False)
                print(f"Processed {file}")
            else:
                print(f"File not processed. Only CSV files are supported: {file}")
