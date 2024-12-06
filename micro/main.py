from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import os

app = Flask(__name__)

requests_total = Counter('requests_total', 'Total HTTP Requests')

def get_host_type():
    if os.path.exists('/.dockerenv'):
        return 'container'
    elif os.path.exists('/proc/vz'):
        return 'virtual_machine'
    else:
        return 'physical_server'

@app.route('/')
def metrics():
    requests_total.inc()
    response = generate_latest(requests_total)
    response += f'host_type {get_host_type()}\n'.encode()
    return response, 200, {'Content-Type': CONTENT_TYPE_LATEST}


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
