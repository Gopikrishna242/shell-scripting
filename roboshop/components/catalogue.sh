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
cd /home/roboshop && rm -rf catalogue && unzip -o /tmp/catalogue.zip &>>$LOG && mv catalogue-main catalogue && cd /home/roboshop/catalogue && npm install &>>$LOG && chown roboshop:roboshop /home/roboshop -R
Stat $?

Head "Update EndPoints in Service File"
sed -i -e "s/MONGO_DNSNAME/ip-172-31-28-183.ec2.internal/" /home/roboshop/catalogue/systemd.service
Stat $?


Head "Setup SystemD Service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service && systemctl daemon-reload && systemctl start catalogue && systemctl enable catalogue &>>$LOG
Stat $?
