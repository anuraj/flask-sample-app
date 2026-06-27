# run.py

from app import app

if __name__ == '__main__':
    # Bind to all interfaces so the app is reachable when running in Docker.
    app.run(host='0.0.0.0')

