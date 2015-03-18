#!/bin/bash

#initialize variables
SERVICE_DOWN="0"
SERVICE_MESSAGE="<html><b>Service status</b><br/>"
SERVICE_EMAIL_SUBJECT="All Services are up."
JENKINS_PID=""
HAR_PID=""
MONGO_PID=""

function sendStatusEmail {
	`/root/email/send_email --subject "${SERVICE_EMAIL_SUBJECT}" --to "rmcginnis@stubhub.com" -m "${SERVICE_MESSAGE}"`
}

function checkServices {
	JENKINS_PID=$(ps -ef | grep JENKINS_HOME | grep -v "grep" | awk '{print $2}')
	MONGO_PID=$(ps -ef | grep mongod | grep -v "grep" | awk '{print $2}')
	HAR_PID=$(ps -ef | grep "paster serve" | grep -v "grep" | awk '{print $2}')
}

function markServiceUpDown {
	if [ "$JENKINS_PID" == "" ]; then
		SERVICE_DOWN="1"
		SERVICE_MESSAGE="$SERVICE_MESSAGE <br/> Jenkins <font color='red'>DOWN</font>"
		sh /opt/jenkins/startJenkins.sh &
		echo "Jenkins down"
	else
		SERVICE_MESSAGE="$SERVICE_MESSAGE <br/> Jenkins <font color='green'>UP</font>"
		echo "Jenkins up" 
	fi

	if [ "$MONGO_PID" == "" ]; then
		SERVICE_DOWN="1"
		SERVICE_MESSAGE="$SERVICE_MESSAGE <br/> Mongo <font color='red'>DOWN</font>"
		`service mongod start`
		echo "Mongo down"
	else
		SERVICE_MESSAGE="$SERVICE_MESSAGE <br/> Mongod <font color='green'>UP</font>"
		echo "Mongo up"
	fi

	if [ "$HAR_PID" == "" ]; then
		SERVICE_DOWN="1"
		SERVICE_MESSAGE="$SERVICE_MESSAGE <br/> HarStorage <font color='red'>DOWN</font></html>" 
		sh /opt/harstorage-1.0/startHarStorage.sh &
		echo "HarStorage down"
	else
		SERVICE_MESSAGE="$SERVICE_MESSAGE <br/> HarStorage <font color='green'>UP</font> </html>"
		echo "HarStorage up"
	fi

	if [ "$SERVICE_DOWN" == "1" ]; then
		SERVICE_EMAIL_SUBJECT="ALERT: One ore more services were down and has been restarted!"
		sendStatusEmail
		sleep 20
	fi
}

checkServices
markServiceUpDown
sendStatusEmail




