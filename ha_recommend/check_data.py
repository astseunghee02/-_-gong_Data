# check_data.py
import sqlite3

conn = sqlite3.connect("fitness.db")
cur = conn.cursor()

cur.execute("SELECT * FROM FITNESS_MEASURE;")
rows = cur.fetchall()

for r in rows:
    print(r)

conn.close()
