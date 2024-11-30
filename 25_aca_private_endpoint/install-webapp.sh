#!/bin/bash

sudo apt install nginx -y

IP=$(hostname -i)

echo "Hello from virtual machine: $HOSTNAME, with IP address: $IP" > /var/www/html/index.html