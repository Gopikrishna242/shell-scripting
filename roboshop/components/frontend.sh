#!/bin/bash

source components/common.sh

DOMAIN="zsdevops01.online"

OS_PREREQ

Head "Installing Nginx"
apt install nginx -y &>>$LOG
Stat $?

DOWNLOAD_COMPONENT

Head "Remove Default Configuration"
rm -rf /var/www/html /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
Stat $?

Head "Unzip Downloaded Archive"
cd /var/www && unzip -o /tmp/frontend.zip &>>$LOG && mv frontend-main/* . && mv static html && rm -rf frontend-main README.md
Stat $?

Head "Update Nginx Configuration"
mv roboshop.conf /etc/nginx/sites-enabled/roboshop.conf
#for comp in catalogue cart user shipping payment ; do
  #sed -i -e "/$comp/ s/localhost/${comp}.ec2-54-90-123-13.compute-1.amazonaws.com/" /etc/nginx/sites-enabled/roboshop.conf
#done
Stat $?

Head "Restart Nginx Service"
systemctl restart nginx
Stat $?

