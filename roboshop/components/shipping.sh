#!/bin/bash

source components/common.sh

OS_PREREQ

Head "Install Maven"
apt install maven -y &>>$LOG
Stat $?


Head "Adding RoboShop User"
id roboshop &>>$LOG
if [ $? -ne 0 ]; then
  useradd -m -s /bin/bash roboshop
  Stat $?
fi

DOWNLOAD_COMPONENT

Head "Extract Downloaded Archive"
cd /home/roboshop && rm -rf shipping && unzip -o /tmp/shipping.zip &>>$LOG && mv shipping-main shipping && cd /home/roboshop/shipping &&  mvn clean package  &>>$LOG && chown roboshop:roboshop /home/roboshop -R && mv target/shipping-1.0.jar shipping.jar  &>>$LOG
Stat $?

Head "Update EndPoints in Service File"
sed -i -e "s/CARTENDPOINT/ip-172-31-28-196.ec2.internal/" -e "s/DBHOST/ip-172-31-25-200.ec2.internal/" /home/roboshop/shipping/systemd.service
Stat $?


Head "Setup SystemD Service"
mv /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service && systemctl daemon-reload && systemctl start shipping && systemctl enable shipping &>>$LOG
Stat $?
