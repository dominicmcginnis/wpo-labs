#!/bin/sh

WPT_TEST_URL="http://www.webpagetest.org/runtest.php"
WPT_HAR_DOWNLOAD_URL="http://www.webpagetest.org/export.php"
WPT_TEST_STATUS_URL="http://www.webpagetest.org/testStatus.php?f=xml"

#LOCATION="Dulles:Chrome.DSL"
LOCATION="Dulles_IE9.DSL"
URL=""
RUNS="1"
API_KEY=""
PRIVATE="1"
VIDEO="1"

NOW=`date '+%Y-%m-%d-%H-%M-%S'`

SLEEP_DURATION=120

if [ "$1" != "" ]; then
	URL=$1;
else 
	echo "Usage: runWPTTest.sh <URL> <NumOfRuns>";
	echo "   <URL> is a required paramater";
	echo "   <NumOfRuns> is an option paramater";
	exit;
fi
if [ "$2" != "" ]; then
	RUNS=$2;
fi

if [ $API_KEY == "" ]; then
	echo "You must supply an API Key";
	exit;
fi

WORKING_DIR="/Users/rmcginnis/wpt/scripts/working"
HAR_DIR="/Users/rmcginnis/harviewer/harfiles"

#Replace bad filesystem chars within the files
HAR_FILE=`echo $URL-$NOW.har |sed -e "s/\//-/g" | sed -e "s/?/-/g" | sed -e "s/=/-/g"`
RESULT_FILE=`echo $URL-$NOW-results.xml |sed -e "s/\//-/g" | sed -e "s/?/-/g" | sed -e "s/=/-/g"`
STATUS_FILE=`echo $URL-$NOW-status.xml |sed -e "s/\//-/g" | sed -e "s/?/-/g" | sed -e "s/=/-/g"`

curl -s "$WPT_TEST_URL?location=$LOCATION&runs=$RUNS&f=xml&k=$API_KEY&video=$VIDEO&private=$PRIVATE&url=$URL" > $WORKING_DIR/$RESULT_FILE

RESULT=`xmllint --xpath "/response/statusCode/text()" $WORKING_DIR/$RESULT_FILE`
echo "Checking results file for status $WORKING_DIR/$RESULT_FILE"

if [ "200" -eq $RESULT ]; then
	echo "Success scheduling test."
	TEST_ID=`xmllint --xpath "/response/data/testId/text()" $WORKING_DIR/$RESULT_FILE`

	STATUS="100"

	echo "Test ID for test is: $TEST_ID"
	echo "Status checks will be saved to $WORKING_DIR/$STATUS_FILE"

	# Check the status of the job
	while [ $STATUS -ne "200" ]
	do 
		echo "Job not completed yet, sleeping $SLEEP_DURATION seconds"
		sleep $SLEEP_DURATION 

		echo "Waking - Checking job status for test $TEST_ID"
		curl -s "$WPT_TEST_STATUS_URL&test=$TEST_ID&k=$API_KEY" > $WORKING_DIR/$STATUS_FILE
		STATUS=`xmllint --xpath "/response/statusCode/text()" $WORKING_DIR/$STATUS_FILE`
	done

	# Job is complete, dowload the results
	echo "Job completed downloading har file to $HAR_DIR/$HAR_FILE"	
	curl -s "$WPT_HAR_DOWNLOAD_URL?test=$TEST_ID&k=$API_KEY" > $HAR_DIR/$HAR_FILE

	echo "Cleaning up working folder"
	rm $WORKING_DIR/$RESULT_FILE 
	rm $WORKING_DIR/$STATUS_FILE
else
	echo "Test failed"
fi
