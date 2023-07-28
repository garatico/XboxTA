import glob
import pandas as pd

from src.py.scrape.scrape_leaderboard import *

def combine_leaderboard_csv_files():
    csv_files = glob.glob('./data/leaderboard/leaderboard*.csv')
    df_list = []
    for file in csv_files:
        df = pd.read_csv(file)
        df['Bio'] = df['GamerTag'].str.split('\n').str[1]
        df['GamerTag'] = df['GamerTag'].str.split('\n').str[0]
        df_list.append(df)
    combined_df = pd.concat(df_list, ignore_index=True)
    combined_df.to_csv('./data/leaderboard/leaderboard.csv', index=False)
