def create_lb_tb_if_exists(conn, sample, column_types):
    cursor = conn.cursor()

    # Drop the leaderboard table if it exists
    cursor.execute("DROP TABLE IF EXISTS leaderboard")

    # Convert specific columns to the desired numeric types
    numeric_columns = ['Position', 'Score']
    for column in numeric_columns:
        sample[column] = sample[column].str.replace(',', '').astype(int)

    # Construct the columns and types string
    columns_types_str = ', '.join([f'{col} {col_type}' for col, col_type in zip(sample.columns, column_types)])

    # Create the leaderboard table
    create_table_query = f"CREATE TABLE IF NOT EXISTS leaderboard ({columns_types_str})"
    cursor.execute(create_table_query)
    cursor.close()

def insert_values_into_lb_tb(conn, sample):
    column_names = sample.columns.tolist()
    column_names_str = ', '.join(column_names)

    cursor = conn.cursor()
    placeholders = ', '.join(['?'] * len(column_names))
    insert_query = f"INSERT INTO leaderboard ({column_names_str}) VALUES ({placeholders})"

    for index, row in sample.iterrows():
        row_insert = row.tolist()
        cursor.execute(insert_query, row_insert)

    conn.commit()





