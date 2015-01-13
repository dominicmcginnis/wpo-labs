#!/bin/sh

#Used for jenkins
#mkdir $WORKSPACE/$BUILD_NUMBER
#mkdir $WORKSPACE/$BUILD_NUMBER/working
#mkdir $WORKSPACE/$BUILD_NUMBER/harfiles

#When using with Jenkins comment out as those should be parameters set by jenkins 
LABEL=$2
URL=$1

WPT_URL="http://perfhub.stubcorp.dev:9494"
WPT_TEST_URL="$WPT_URL/runtest.php"
WPT_HAR_DOWNLOAD_URL="$WPT_URL/export.php"
WPT_TEST_STATUS_URL="$WPT_URL/testStatus.php?f=xml"

HARSTORAGE_URL="http://localhost:5000"

LOCATION="Test:Chrome.3G"
RUNS="1"
PRIVATE="0"
VIDEO="1"
FVONLY="1"
MOBILE="1"

NOW=`date '+%Y-%m-%d-%H-%M-%S'`

SLEEP_DURATION=120

WORKING_DIR="./working"
HAR_DIR="./harfiles"

# Used with Jenkins
#WORKING_DIR="$WORKSPACE/$BUILD_NUMBER/working"
#HAR_DIR="$WORKSPACE/$BUILD_NUMBER/harfiles"

#Replace bad filesystem chars within the files
BASE_FILE=`echo $URL-$NOW |sed -e "s/http:\/\///g" |sed -e "s/\//-/g" | sed -e "s/?/-/g" | sed -e "s/=/-/g"`
HAR_FILE=$BASE_FILE.har
RESULT_FILE=$BASE_FILE-results.xml
STATUS_FILE=$BASE_FILE-status.xml

URL="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$URL")"

curl -s "$WPT_TEST_URL?location=$LOCATION&runs=$RUNS&f=xml&video=$VIDEO&fvonly=$FVONLY&private=$PRIVATE&label=$LABEL&mobile=$MOBILE&url=$URL" > $WORKING_DIR/$RESULT_FILE
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
		curl -s "$WPT_TEST_STATUS_URL&test=$TEST_ID" > $WORKING_DIR/$STATUS_FILE
		STATUS=`xmllint --xpath "/response/statusCode/text()" $WORKING_DIR/$STATUS_FILE`
	done

	# Job is complete, dowload the results
	echo "Job completed downloading har file to $HAR_DIR/$HAR_FILE"	
	curl -s "$WPT_HAR_DOWNLOAD_URL?test=$TEST_ID" > $HAR_DIR/$HAR_FILE

	# Set the proper label for the test
	cat $HAR_DIR/$HAR_FILE | sed -e "s/\"title\"/\"label\":\"$LABEL\",\"title\"/" > $HAR_DIR/$HAR_FILE.new
	mv  $HAR_DIR/$HAR_FILE.new $HAR_DIR/$HAR_FILE

	# Set a "source" element so we can click to the WPT Test from anywhere
	cat $HAR_DIR/$HAR_FILE | sed -e "s#\"creator\":[{]#\"creator\":{\"source\":\"$WPT_URL/result/$TEST_ID/\",#" > $HAR_DIR/$HAR_FILE.new
	mv  $HAR_DIR/$HAR_FILE.new $HAR_DIR/$HAR_FILE

	echo "Uploading to harstorage"
	curl -s -X POST --form "file=@$HAR_DIR/$HAR_FILE" --header "Automated: true" $HARSTORAGE_URL/results/upload

	echo "Cleaning up working folder"
	rm $WORKING_DIR/$RESULT_FILE 
	rm $WORKING_DIR/$STATUS_FILE

	exit 0
else
	echo "Test failed"
	exit 100
fi
