#!/bin/bash
set -e

APP_DIR="/home/azureuser/simple-api"
APP_NAME="simple-api" # Name for the pipx application
PIPX_HOME="/home/azureuser/.local/pipx" #Setting pipx home directory

#Navigate to app directory
cd "${APP_DIR}"

# Stop any existing process on port 80
echo "Attempting to stop any process on port 80..."
sudo fuser -k 80/tcp || echo "Port 80 was not in use, or fuser command failed."

# Ensure pipx is installed
echo "Ensuring pipx is installed..."
if ! command -v pipx &> /dev/null
then
    echo "pipx not found, installing..."
    sudo apt update && sudo apt install -y pipx
    if [ $? -ne 0 ]; then
      echo "Failed to install pipx.  Ensure it is installed on the VM and try again."
      exit 1
    fi
fi

#Make sure pipx is in path
export PATH="$PATH:/home/azureuser/.local/bin"
pipx ensurepath

# Install the application using pipx
echo "Installing the application using pipx..."
pipx install --python python3 --force "${APP_DIR}"

# Start the application
echo "Starting the application..."
nohup "${PIPX_HOME}/venvs/${APP_NAME}/bin/python" app.py > "${APP_DIR}/app.log" 2>&1 &

echo "Deployment script finished."
