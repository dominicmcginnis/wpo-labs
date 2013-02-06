#!/bin/sh

YSLOW_LOC=/Users/rmcginnis/yslow
REPORTS_LOC=$YSLOW_LOC/reports
NOW=`date '+%Y-%m-%d-%H-%M-%S'`

# if no command line arg given
# set to home 
if [ -z $1 ]
then
  echo "No supplied page, running for the home page"
  PAGE="home"
elif [ -n $1 ]
then
# otherwise make first arg as PAGE 
  PAGE=$1
fi

REPORT=$REPORTS_LOC/$PAGE_$NOW.html

case $PAGE in 
	"home") URL=http://www.stubhub.com";;
	*) URL=http://www.stubhub.com";;
esac

beginTemplate() {
	echo "<html><body><p>"
}

endTemplate() {
	echo "</p></body></html>"
}

beginTemplate >> $REPORT
echo "Home Page $NOW </br>" >> $REPORT 
phantomjs $YSLOW_LOC/yslow.js --format xml $URL  >> $REPORT
endTemplate >> $REPORT
perl -pi -e 's/\n/<\/br>/' $REPORT
