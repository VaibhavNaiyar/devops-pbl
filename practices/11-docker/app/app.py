from flask import Flask, jsonify
import os, socket, redis

app = Flask(__name__)
r = redis.Redis(host=os.getenv("REDIS_HOST", "redis"), port=6379)

@app.route("/")
def index():
    try:
        hits = r.incr("hits")
    except redis.exceptions.ConnectionError:
        hits = "redis unavailable"
    return jsonify(message="Hello from Docker!", container=socket.gethostname(), hits=hits)

@app.route("/health")
def health():
    return "ok", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
