import re

def create_lb_tb_if_exists(conn):
    cursor = conn.cursor()

    # Drop the leaderboard table if it exists
    drop_table_query = "DROP TABLE IF EXISTS leaderboard"
    cursor.execute(drop_table_query)

    # Create the leaderboard table
    create_table_query = "CREATE TABLE leaderboard (GamerTag VARCHAR(255), Position INT, Score INT, Achievement_File VARCHAR(255), Game_File VARCHAR(255))"
    cursor.execute(create_table_query)

    cursor.close()

def insert_values_into_lb_tb(conn, sample):
    column_names = ['GamerTag', 'Score', 'Position']
    cursor = conn.cursor()

    for _, row in sample.iterrows():
        values = [row[column] for column in column_names]

        # Remove commas and non-numeric characters from 'Score'
        values[1] = int(values[1].replace(',', ''))

        # Remove non-numeric characters from 'Position'
        position_value = re.sub(r'[^0-9]', '', values[2])
        values[2] = int(position_value) if position_value else None  # Convert to int or set to None

        placeholders = ', '.join(['?'] * len(column_names))
        insert_query = f"INSERT INTO leaderboard ({', '.join(column_names)}) VALUES ({placeholders})"
        cursor.execute(insert_query, values)

    conn.commit()
    cursor.close()









