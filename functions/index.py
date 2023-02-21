import http.client
import json
import os

def handler(event, context):
    app_url = os.environ['APP_URL']
    print(app_url)
    conn = http.client.HTTPSConnection(app_url)
    payload = json.dumps({
        "taskId": "First Things First",
        "taskDescription": "Define your application"
    })
    headers = {
      'Content-Type': 'application/json'
    }
    conn.request("POST", "/todos", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))