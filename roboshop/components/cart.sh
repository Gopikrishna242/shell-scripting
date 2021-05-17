#!/bin/bash

source components/common.sh

OS_PREREQ

Head "Install NPM"
apt install npm -y &>>$LOG
Stat $?

Head "Adding RoboShop User"
id roboshop &>>$LOG
if [ $? -ne 0 ]; then
  useradd -m -s /bin/bash roboshop
  Stat $?
fi



DOWNLOAD_COMPONENT

Head "Extracting Downloaded Archive"
cd /home/roboshop && rm -rf cart && unzip -o /tmp/cart.zip &>>$LOG && mv cart-main cart && cd /home/roboshop/cart && npm install &>>$LOG && chown roboshop:roboshop /home/roboshop -R
Stat $?

Head "Update EndPoints in Service File"
sed -i -e "s/REDIS_ENDPOINT/ip-172-31-22-79.ec2.internal/" -e "s/CATALOGUE_ENDPOINT/ip-172-31-18-234.ec2.internal/" /home/roboshop/cart/systemd.service
Stat $?


Head "Setup SystemD Service"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service && systemctl daemon-reload && systemctl start cart && systemctl enable cart &>>$LOG
Stat $?
