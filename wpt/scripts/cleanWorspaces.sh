#!/bin/bash
kill $(ps -ef | grep JENKINS_HOME | awk '{print $2}')
cd /opt/jenkins/jobs
for i in $( find -maxdepth 2 -type d -name workspace ); do
    echo item: $i
    rm -rf $i
    mkdir $i
done
cd /opt/jenkins
./startJenkins.sh &
