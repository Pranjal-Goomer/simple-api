# Disabled old workflow
# This file has been replaced by simple_deploy.yml 

name: Deploy API

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Copy files
        uses: appleboy/scp-action@master
        with:
          host: 20.62.249.125
          username: azureuser
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          source: "app.py,requirements.txt"
          target: "~/simple-api"
      
      - name: Run application
        uses: appleboy/ssh-action@master
        with:
          host: 20.62.249.125
          username: azureuser
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd ~/simple-api
            source venv/bin/activate
            sudo pkill -f "python3 app.py" || true
            sudo nohup $(which python3) app.py > app.log 2>&1 &
            echo "API running on port 80" 
