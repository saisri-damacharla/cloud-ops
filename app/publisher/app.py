from flask import Flask, request, jsonify
from google.cloud import pubsub_v1, secretmanager
import json
import os

app = Flask(__name__)

PROJECT_ID = os.getenv("PROJECT_ID")
TOPIC_ID   = os.getenv("TOPIC_ID", "ops-topic")
SECRET_ID  = os.getenv("SECRET_ID", "APP_API_KEY")

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)

def get_api_key():
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{PROJECT_ID}/secrets/{SECRET_ID}/versions/latest"
    response = client.access_secret_version(name=name)
    return response.payload.data.decode("utf-8")

@app.route("/", methods=["GET"])
def health():
    return jsonify(status="ok"), 200

@app.route("/publish", methods=["POST"])
def publish():
    # Simple API Key check via header
    api_key = request.headers.get("x-api-key")
    if api_key != get_api_key():
        return jsonify(error="unauthorized"), 401

    data = request.get_json(silent=True) or {}
    payload = json.dumps(data).encode("utf-8")
    future = publisher.publish(topic_path, payload, source="publisher")
    msg_id = future.result()
    return jsonify(message_id=msg_id), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
