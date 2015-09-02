#!/bin/sh

WPT_URL="http://www.webpagetest.org"
WPT_TEST_URL="http://www.webpagetest.org/runtest.php"
WPT_HAR_DOWNLOAD_URL="http://www.webpagetest.org/export.php"
WPT_TEST_STATUS_URL="http://www.webpagetest.org/testStatus.php?f=xml"

HARSTORAGE_URL="http://localhost:5000"

WORKING_DIR="/Users/rmcginnis/wpt/scripts/working"
HAR_DIR="/Users/rmcginnis/harviewer/harfiles"

LOCATION="Dulles:Chrome.Cable"
RUNS="1"
PRIVATE="0"
VIDEO="1"
FVONLY="1"
MOBILE="1"

NOW=`date '+%Y-%m-%d-%H-%M-%S'`

SLEEP_DURATION=120

function usage {
    echo "Usage: runWPTTest.sh <API_KEY> <TEST> <label> <NumOfRuns> <IS_SCRIPT>";
    echo "   <API_KEY> is a required paramater";
    echo "   <TEST> is a required paramater";
    echo "   <label> is an optional paramater";
    echo "   <NumOfRuns> is an optional paramater";
    echo "   <IS_SCRIPT> is an optional paramater - set to Yes if the supplied <TEST> is a script and not a URL";
    exit;
}

if [ "$1" != "" ]; then
        API_KEY=$1;
else
	usage;
fi

if [ "$2" != "" ]; then
        TEST=$2;
else
	usage;
fi

if [ "$3" != "" ]; then
        LABEL=$3;
fi

if [ "$4" != "" ]; then
        RUNS=$4;
fi

if [ "$5" != "" ]; then
        IS_SCRIPT=$5;
else 
	IS_SCRIPT="N"
fi


#Replace bad filesystem chars within the files
BASE_FILE=`echo $LABEL-$NOW |sed -e "s/http:\/\///g" |sed -e "s/\//-/g" | sed -e "s/?/-/g" | sed -e "s/=/-/g"`
HAR_FILE=$BASE_FILE.har
RESULT_FILE=$BASE_FILE-results.xml
STATUS_FILE=$BASE_FILE-status.xml

TEST_URL="$WPT_TEST_URL?location=$LOCATION&runs=$RUNS&f=xml&k=$API_KEY&video=$VIDEO&fvonly=$FVONLY&private=$PRIVATE&label=$LABEL&mobile=$MOBILE"

if [ "$IS_SCRIPT" == "Y" ]; then
    TEST_URL="$TEST_URL&script=$TEST"
else
    TEST_URL="$TEST_URL&url=$TEST"
fi

url=$URL
curl -s "$TEST_URL" > $WORKING_DIR/$RESULT_FILE
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
		curl -s "$WPT_TEST_STATUS_URL&k=$API_KEY&test=$TEST_ID" > $WORKING_DIR/$STATUS_FILE
		STATUS=`xmllint --xpath "/response/statusCode/text()" $WORKING_DIR/$STATUS_FILE`
	done

	# Job is complete, dowload the results
	echo "Job completed downloading har file to $HAR_DIR/$HAR_FILE"	
	curl -s "$WPT_HAR_DOWNLOAD_URL?k=$API_KEY&test=$TEST_ID" > $HAR_DIR/$HAR_FILE

    # Set the proper label for the test
	cat $HAR_DIR/$HAR_FILE | sed -e "s/\"title\"/\"label\":\"$LABEL\",\"title\"/" > $HAR_DIR/$HAR_FILE.new
	mv  $HAR_DIR/$HAR_FILE.new $HAR_DIR/$HAR_FILE

    # Set a "source" element so we can click to the WPT Test from anywhere
    #    cat $HAR_DIR/$HAR_FILE | sed -e "s#\"creator\":[{]#\"creator\":{\"source\":\"$WPT_URL/result/$TEST_ID/\",#" > $HAR_DIR/$HAR_FILE.new
    #    mv  $HAR_DIR/$HAR_FILE.new $HAR_DIR/$HAR_FILE

    # I've noticed that when using script elements and controlling the logdata steps 
    # we sometimes get invalid har files - i.e. logging is missing.  So before we 
    # attempt to process, lets check for validity
    #echo "Checking for valid entries"
    #ENTRIES_SIZE=cat $HAR_DIR/$HAR_FILE | jq '.entries | length'

    #if [ "0" -eq $ENTRIES_SIZE ]; then
    #   echo "Test failed" 
    #   exit 100
    #else
    #   echo "Passed validity check"
    #fi

#	echo "Uploading to harstorage"
#	HAR_RESPONSE=`curl -s -X POST --form "file=@$HAR_DIR/$HAR_FILE" --header "Automated: true" $HARSTORAGE_URL/results/upload`

#   if [ "Successful" != "$HAR_RESPONSE" ]; then
#       echo "Test failed, invalid HAR"
#       exit 100
#   fi

	echo "Cleaning up working folder"
	#rm $WORKING_DIR/$RESULT_FILE 
	#rm $WORKING_DIR/$STATUS_FILE

	exit 0
else
	echo "Test failed"
	exit 100
fi
