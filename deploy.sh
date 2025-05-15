#!/bin/bash
# Stop the current process
fuser -k 80/tcp

# Start application
nohup python app.py &
