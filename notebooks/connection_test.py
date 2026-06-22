import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='1234',
    database='saas_funnel'
)

print("Connected successfully")
conn.close()