#!/bin/bash

source components/common.sh

OS_PREREQ

Head "Install RabbitMQ Repos"
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | apt-key add - &>>$LOG
Stat $?

Head "Setup RabbitMQ Sources"
apt install apt-transport-https -y &>>$LOG && #echo -e "deb https://dl.bintray.com/rabbitmq-erlang/debian focal erlang\ndeb https://dl.bintray.com/rabbitmq/debian bionic main" > /etc/apt/sources.list.d/bintray.rabbitmq.list && apt update -y &>>$LOG
&& echo -e "deb https://dl.bintray.com/rabbitmq-erlang/debian focal erlang\ndeb https://dl.bintray.com/rabbitmq/debian bionic main" > /etc/apt/sources.list.d/bintray.rabbitmq.list
Stat $?

Head "Install RabbitMQ"
apt install rabbitmq-server -y --fix-missing &>>$LOG
Stat $?

Head "Setup Application User and Setup Permissions"
rabbitmqctl list_users | grep roboshop &>>$LOG
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop roboshop123 &>>$LOG && rabbitmqctl set_user_tags roboshop administrator &>>$LOG && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG
else
  rabbitmqctl set_user_tags roboshop administrator &>>$LOG && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG
fi
Stat $?

