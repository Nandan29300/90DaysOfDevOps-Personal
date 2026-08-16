import os
import time

import psycopg2
import redis
from flask import Flask

app = Flask(__name__)


# Connect to PostgreSQL
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "db"),
        database=os.getenv("POSTGRES_DB", "devops"),
        user=os.getenv("POSTGRES_USER", "devops"),
        password=os.getenv("POSTGRES_PASSWORD", "devops_password"),
    )


# Connect to Redis
def get_redis_connection():
    return redis.Redis(
        host=os.getenv("REDIS_HOST", "redis"),
        port=6379,
        decode_responses=True,
    )


# Create the table when PostgreSQL is ready
def initialize_database():
    for attempt in range(10):
        try:
            connection = get_db_connection()

            with connection:
                with connection.cursor() as cursor:
                    cursor.execute(
                        """
                        CREATE TABLE IF NOT EXISTS visits (
                            id SERIAL PRIMARY KEY,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                        )
                        """
                    )

            connection.close()
            print("PostgreSQL is ready.")
            return

        except psycopg2.OperationalError as error:
            print(f"Database not ready yet: {error}")
            time.sleep(2)

    raise RuntimeError("Could not connect to PostgreSQL.")


# Main page
@app.route("/")
def home():
    connection = get_db_connection()

    with connection:
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO visits DEFAULT VALUES")
            cursor.execute("SELECT COUNT(*) FROM visits")
            visit_count = cursor.fetchone()[0]

    connection.close()

    cache = get_redis_connection()
    cache.set("last_message", "Hello from Redis!")

    cached_message = cache.get("last_message")

    return f"""
    <h1>Day 34 - Docker Compose</h1>
    <p>Flask application is running.</p>
    <p>PostgreSQL visits: {visit_count}</p>
    <p>Redis message: {cached_message}</p>
    """


# Health endpoint
@app.route("/health")
def health():
    return "OK", 200


if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000)
