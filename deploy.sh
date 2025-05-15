#!/bin/bash
set -e

APP_DIR="/home/azureuser/simple-api"
VENV_DIR="${APP_DIR}/venv"

mkdir -p "${APP_DIR}"
cd "${APP_DIR}"

echo "Stopping any process on port 80..."
if command -v fuser &> /dev/null; then
  sudo fuser -k 80/tcp || echo "No process on port 80 or failed to stop."
else
  echo "fuser not found; ensure port 80 is free."
fi

echo "Checking for python3-venv package..."
if ! dpkg -s python3-venv > /dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y python3-venv
fi

if [ ! -d "${VENV_DIR}" ]; then
  echo "Creating virtual environment..."
  python3 -m venv "${VENV_DIR}"
fi

echo "Installing dependencies..."
"${VENV_DIR}/bin/python" -m pip install --upgrade pip
"${VENV_DIR}/bin/python" -m pip install -r requirements.txt

echo "Starting the Flask application..."
nohup "${VENV_DIR}/bin/python" app.py > "${APP_DIR}/app.log" 2>&1 &

echo "Deployment complete. Logs at ${APP_DIR}/app.log"
