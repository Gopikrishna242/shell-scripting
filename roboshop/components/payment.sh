#!/bin/bash

source components/common.sh

OS_PREREQ


Head "Adding RoboShop User"
id roboshop &>>$LOG
if [ $? -ne 0 ]; then
  useradd -m -s /bin/bash roboshop
  Stat $?
fi

DOWNLOAD_COMPONENT

Head "Install Python3 Pip"
apt install python3-pip -y &>>$LOG
Stat $?

Head "Extract Downloaded Archive"
cd /home/roboshop && rm -rf payment && unzip -o /tmp/payment.zip &>>$LOG && mv payment-main payment && cd /home/roboshop/payment &&  pip3 install -r requirements.txt  &>>$LOG && chown roboshop:roboshop /home/roboshop -R
Stat $?


USER_ID=$(id -u roboshop)
GROUP_ID=$(id -g roboshop)

Head "Update Payment Configuration"
sed -i -e "/^uid/ c uid = ${USER_ID}" -e  "/^gid/ c gid = ${GROUP_ID}"  /home/roboshop/payment/payment.ini
Stat $? 


Head "Update EndPoints in Service File"
sed -i -e "s/CARTHOST/ip-172-31-28-196.ec2.internal/" -e "s/USERHOST/ip-172-31-16-137.ec2.internal/" -e "s/RMQPHOST/ip-172-31-18-124.ec2.internal/" /home/roboshop/payment/systemd.service
Stat $?


Head "Setup SystemD Service"
mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service && systemctl daemon-reload && systemctl start payment && systemctl enable payment &>>$LOG
Stat $?
