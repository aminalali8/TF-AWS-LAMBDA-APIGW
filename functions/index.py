import http.client
import random
import string
import json
import os

def handler(event, context):
    letters = string.ascii_lowercase
    title = ''.join(random.choice(letters) for i in range(10))
    description = ''.join(random.choice(letters) for i in range(20))
    conn = http.client.HTTPSConnection("backend-tksd7k.bunnyenv.com")
    payload = 'title='+title+'&description='+description
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    conn.request("POST", "/books", payload, headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))