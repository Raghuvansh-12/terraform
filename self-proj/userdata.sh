#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx
echo "<h1>NGINX from Launch Template</h1>" > /usr/share/nginx/html/index.html