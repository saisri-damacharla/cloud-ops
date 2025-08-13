from concurrent.futures import TimeoutError
from google.cloud import pubsub_v1, secretmanager
import os
import json
import time

PROJECT_ID   = os.getenv("PROJECT_ID")
SUB_ID       = os.getenv("SUB_ID", "ops-sub")
SECRET_ID    = os.getenv("SECRET_ID", "APP_API_KEY")
TIMEOUT      = 60.0

def get_api_key():
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{PROJECT_ID}/secrets/{SECRET_ID}/versions/latest"
    response = client.access_secret_version(name=name)
    return response.payload.data.decode("utf-8")

def main():
    # Demonstrate secret fetch on startup
    api_key = get_api_key()
    print(f"[worker] secret APP_API_KEY loaded, length={len(api_key)}")

    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(PROJECT_ID, SUB_ID)

    def callback(message: pubsub_v1.subscriber.message.Message) -> None:
        try:
            payload = json.loads(message.data.decode("utf-8"))
        except Exception:
            payload = {"raw": message.data.decode("utf-8")}
        print(f"[worker] received: {payload}, attributes={dict(message.attributes)}")
        message.ack()

    streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
    print(f"[worker] listening on {subscription_path}")

    try:
        streaming_pull_future.result(timeout=TIMEOUT)
    except TimeoutError:
        streaming_pull_future.cancel()

if __name__ == "__main__":
    while True:
        main()
        time.sleep(1)
