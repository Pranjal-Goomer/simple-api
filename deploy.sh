#!/bin/bash
set -e

APP_DIR="/home/azureuser/simple-api"
VENV_DIR="${APP_DIR}/venv"

# Ensure the application directory exists
mkdir -p "${APP_DIR}"
cd "${APP_DIR}"

# Stop any existing process on port 80
echo "Stopping any process on port 80..."
if command -v fuser &> /dev/null; then
    sudo fuser -k 80/tcp || echo "No process on port 80 or failed to stop."
else
    echo "fuser not found; ensure port 80 is free."
fi

# Create a virtual environment
echo "Creating virtual environment..."
python3 -m venv "${VENV_DIR}"

# Activate the virtual environment and install dependencies
echo "Installing dependencies..."
"${VENV_DIR}/bin/pip" install --upgrade pip
"${VENV_DIR}/bin/pip" install -r requirements.txt

# Run the application
echo "Starting the Flask application..."
nohup "${VENV_DIR}/bin/python" app.py > "${APP_DIR}/app.log" 2>&1 &

echo "Deployment complete. Logs at ${APP_DIR}/app.log"
