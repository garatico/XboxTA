import os
import pandas as pd

def get_file_directory(folder_path):
    file_list = []
    for root, dirs, files in os.walk(folder_path):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            gamertag = file_name.split('_')[0]
            file_list.append({'Gamertag': gamertag, 'FilePath': file_path})
    df = pd.DataFrame(file_list)
    return df

def insert_values_into_directory_tb(conn, sample):
    cursor = conn.cursor()

    column_names = sample.columns.tolist()
    column_names_str = ', '.join(column_names)

    cursor = conn.cursor()
    placeholders = ', '.join(['?'] * len(column_names))
    insert_query = f"INSERT INTO leaderboard ({column_names_str}) VALUES ({placeholders})"

    for index, row in sample.iterrows():
        row_insert = row.tolist()
        cursor.execute(insert_query, row_insert)

    conn.commit()
