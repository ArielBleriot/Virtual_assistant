import sqlite3

# Connect to the database (it will create the file if it doesn't exist)
conn = sqlite3.connect('user_data.db')
cursor = conn.cursor()

# Create a table to store user data
cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER,
    city TEXT
)
''')

# Insert some data into the table
# TODO - add your own data here
cursor.execute('''
INSERT INTO users (name, age, city) VALUES
('John Doe', 25, 'New York'),
('Jane Smith', 30, 'Los Angeles'),
('Mike Brown', 22, 'Chicago')
''')

# Commit the changes to the database
conn.commit()

# Query the database to retrieve the data
cursor.execute('SELECT * FROM users')
rows = cursor.fetchall()

# Display the data
for row in rows:
    print(row)

# Close the connection
conn.close()