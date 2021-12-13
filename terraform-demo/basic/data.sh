#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
echo "Hello, World!" | sudo tee /var/www/html/index.html
sudo systemctl restart apache2
