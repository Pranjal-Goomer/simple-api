#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

APP_DIR="/home/azureuser/simple-api" # Your application directory on the VM
VENV_DIR="${APP_DIR}/venv"

# Ensure the application directory exists
mkdir -p "${APP_DIR}"
cd "${APP_DIR}"

# Stop any existing process on port 80
# This requires 'azureuser' to have passwordless sudo privileges for fuser,
# or fuser needs to be callable without sudo if it doesn't require root.
echo "Attempting to stop any process on port 80..."
if command -v fuser &> /dev/null && [ -x "$(command -v fuser)" ]; then
    sudo fuser -k 80/tcp || echo "Port 80 was not in use, or fuser command failed to stop a process."
else
    echo "fuser command not found or not executable. Skipping process termination. Ensure port 80 is free."
fi

# Check if python3-venv is installed. If not, attempt to install it.
# This requires 'azureuser' to have sudo privileges.
if ! dpkg -s python3-venv > /dev/null 2>&1; then
  echo "python3-venv not found. Attempting to install..."
  sudo apt-get update && sudo apt-get install -y python3-venv
  if [ $? -ne 0 ]; then
    echo "Failed to install python3-venv. Please ensure it is installed on the VM and try again."
    exit 1
  fi
fi

# Create a Python virtual environment if it doesn't already exist
if [ ! -d "${VENV_DIR}" ]; then
  echo "Creating Python virtual environment in ${VENV_DIR}..."
  python3 -m venv "${VENV_DIR}"
fi

# Activate the virtual environment and install dependencies from requirements.txt
echo "Activating virtual environment and installing dependencies..."
source "${VENV_DIR}/bin/activate"
# Ensure pip is up-to-date within the venv
"${VENV_DIR}/bin/pip" install --upgrade pip
# Install requirements
"${VENV_DIR}/bin/pip" install -r requirements.txt
deactivate # Deactivate after installing, nohup will use the venv python

# Start the application using python from the virtual environment
# Output logs to app.log for debugging
echo "Starting the application..."
nohup "${VENV_DIR}/bin/python" app.py > "${APP_DIR}/app.log" 2>&1 &

echo "Deployment script finished. Application should be running."
echo "Check logs at ${APP_DIR}/app.log"
