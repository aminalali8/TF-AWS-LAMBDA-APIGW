import http.client
import random
import string
import json
import os

def handler(event, context):
    letters = string.ascii_lowercase
    app_url = os.environ.get('APP_URL')
    title = ''.join(random.choice(letters) for i in range(10))
    description = ''.join(random.choice(letters) for i in range(20))
    conn = http.client.HTTPSConnection(app_url)
    payload = 'title='+title+'&description='+description
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    conn.request("POST", "/books", payload, headers)
    res = conn.getresponse()
    data = res.read()
    return {
        'message':  data.decode("utf-8")
    }