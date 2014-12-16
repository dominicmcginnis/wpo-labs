#!/bin/sh

OUTPUT_FILE="results.html"


REPORT_URL="http://srwv00dev059.stubcorp.dev:5000/superposed/display"

#array=( one two three )
#for i in "${array[@]}"
#do
#	echo $i
#done

#Not supplied run starting from yesterday
START_DAYS_BACK="1"
#Not supplied run till today
END_DAYS_BACK="0"
if [ ! -z "$1" ] 
then
	START_DAYS_BACK=$1
	echo "Running for Start Day as $START_DAYS_BACK Days ago"
fi

if [ ! -z "$2" ] 
then
	END_DAYS_BACK=$2
	echo "Running for End day as $END_DAYS_BACK Days ago"
fi

START_DATE=`date -v-${START_DAYS_BACK}d +%Y-%m-%d+00:00:00`
END_DATE=`date -v-${END_DAYS_BACK}d +%Y-%m-%d+00:00:00`
DAILY_REPORT="dailyReport_`date -v-${START_DAYS_BACK}d +%Y-%m-%d`-`date -v-${END_DAYS_BACK}d +%Y-%m-%d`.html"

EVENT_TEST_PARAMS="step_1_label=unifiedEvent_cable_prod&"\
"step_1_label=unifiedEvent_cable_prod_TX&"\
"step_1_label=unifiedEvent_cable_prod_VA&"\
"step_1_label_hidden=unifiedEvent_cable_prod%2CunifiedEvent_cable_prod_TX%2CunifiedEvent_cable_prod_VA&"\
"step_1_start_ts=$START_DATE&step_1_end_ts=$END_DATE"

HP_TEST_PARAMS="step_2_label=unifiedHP_cable_prod&"\
"step_2_label=unifiedHP_cable_prod_TX&"\
"step_2_label=unifiedHP_cable_prod_VA&"\
"step_2_label_hidden=unifiedHP_cable_prod%2CunifiedHP_cable_prod_TX%2CunifiedHP_cable_prod_VA&"\
"step_2_start_ts=$START_DATE&step_2_end_ts=$END_DATE"

SEARCH_TEST_PARAMS="step_3_label=unifiedSearchResults_cable_prod&"\
"step_3_label=unifiedSearchResults_cable_prod_TX&"\
"step_3_label=unifiedSearchResults_cable_prod_VA&"\
"step_3_label_hidden=unifiedSearchResults_cable_prod%2CunifiedSearchResults_cable_prod_TX%2CunifiedSearchResults_cable_prod_VA&"\
"step_3_start_ts=$START_DATE&step_3_end_ts=$END_DATE"


TEAM_TEST_PARAMS="step_4_label=unifiedTeam_cable_prod&"\
"step_4_label_hidden=unifiedTeam_cable_prod&"\
"step_4_start_ts=$START_DATE&step_4_end_ts=$END_DATE"
#"step_4_label=unifiedTeam_cable_prod_TX&"\
#"step_4_label=unifiedTeam_cable_prod_VA&"\
#"step_4_label_hidden=unifiedTeam_cable_prod%2unifiedTeam_cable_prod_TX%2unifiedTeam_cable_prod_VA&"\


ARTIST_TEST_PARAMS="step_5_label=unifiedArtist_cable_prod&"\
"step_5_label_hidden=unifiedArtist_cable_prod&"\
"step_5_start_ts=$START_DATE&step_5_end_ts=$END_DATE"
#"step_5_label=unifiedArtist_cable_prod_TX&"\
#"step_5_label=unifiedArtist_cable_prod_VA&"\
#"step_5_label_hidden=unifiedArtist_cable_prod%2unifiedArtist_cable_prod_TX%2unifiedArtist_cable_prod_VA&"\

VENUE_TEST_PARAMS="step_6_label=unifiedVenue_cable_prod&"\
"step_6_label_hidden=unifiedVenue_cable_prod&"\
"step_6_start_ts=$START_DATE&step_6_end_ts=$END_DATE"
#"step_6_label=unifiedVenue_cable_prod_TX&"\
#"step_6_label=unifiedVenue_cable_prod_VA&"\
#"step_6_label_hidden=unifiedVenue_cable_prod%2unifiedVenue_cable_prod_TX%2unifiedVenue_cable_prod_VA&"\

XO_LANDING_TEST_PARAMS="step_7_label=xo_newxo_cable_prod&"\
"step_7_label_hidden=xo_newxo_cable_prod&"\
"step_7_start_ts=$START_DATE&step_7_end_ts=$END_DATE"
#"step_7_label=xo_newxo_cable_prod_TX&"\
#"step_7_label=xo_newxo_cable_prod_VA&"\
#"step_7_label_hidden=xo_newxo_cable_prod%2xo_newxo_cable_prod_TX%2xo_newxo_cable_prod_VA&"\


URL_PARAMS="$EVENT_TEST_PARAMS&"\
"$HP_TEST_PARAMS&"\
"$SEARCH_TEST_PARAMS&"\
"$TEAM_TEST_PARAMS&"\
"$ARTIST_TEST_PARAMS&"\
"$VENUE_TEST_PARAMS&"\
"$XO_LANDING_TEST_PARAMS&"\
"chart=column&table=true&metric=90th%20Percentile"


echo "Running: $REPORT_URL?$URL_PARAMS"
curl -s "$REPORT_URL?$URL_PARAMS" > $OUTPUT_FILE

# extract the summary data
DATA_TABLE=`xmllint --xpath "//div[@id='summary-table']" --html $OUTPUT_FILE`

# Build the report file
echo '<html><head><style>table{border-collapse:collapse;border:1px solid #FF0000;}table th { border:1px solid #FF0000; }table td{border:1px solid #FF0000;}</style></head><body>' > $DAILY_REPORT
echo $DATA_TABLE >> $DAILY_REPORT
echo '</body></html>' >> $DAILY_REPORT

#Define actual report names
REPORT_ROW1="Event Page"
REPORT_ROW2="Home Page"
REPORT_ROW3="Search Results Page"
REPORT_ROW4="Team Page"
REPORT_ROW5="Artist Page"
REPORT_ROW6="Venue Page"
REPORT_ROW7="XO Landing Page"

#modify the label
ROW1_LABEL=`xmllint --xpath "//tbody/tr[1]/td[1]/text()" --html $DAILY_REPORT`
ROW2_LABEL=`xmllint --xpath "//tbody/tr[2]/td[1]/text()" --html $DAILY_REPORT`
ROW3_LABEL=`xmllint --xpath "//tbody/tr[3]/td[1]/text()" --html $DAILY_REPORT`
ROW4_LABEL=`xmllint --xpath "//tbody/tr[4]/td[1]/a/text()" --html $DAILY_REPORT`
ROW5_LABEL=`xmllint --xpath "//tbody/tr[5]/td[1]/a/text()" --html $DAILY_REPORT`
ROW6_LABEL=`xmllint --xpath "//tbody/tr[6]/td[1]/a/text()" --html $DAILY_REPORT`
ROW7_LABEL=`xmllint --xpath "//tbody/tr[7]/td[1]/a/text()" --html $DAILY_REPORT`
#ROW4_LABEL=`xmllint --xpath "//tbody/tr[4]/td[1]/text()" --html $DAILY_REPORT`
#ROW5_LABEL=`xmllint --xpath "//tbody/tr[5]/td[1]/text()" --html $DAILY_REPORT`
#ROW6_LABEL=`xmllint --xpath "//tbody/tr[6]/td[1]/text()" --html $DAILY_REPORT`
#ROW7_LABEL=`xmllint --xpath "//tbody/tr[7]/td[1]/text()" --html $DAILY_REPORT`

cat $DAILY_REPORT | sed -e "s/$ROW1_LABEL/$REPORT_ROW1/g" > $DAILY_REPORT.tmp
cat $DAILY_REPORT.tmp | sed -e "s/$ROW2_LABEL/$REPORT_ROW2/g" > $DAILY_REPORT
cat $DAILY_REPORT | sed -e "s/$ROW3_LABEL/$REPORT_ROW3/g" > $DAILY_REPORT.tmp
cat $DAILY_REPORT.tmp | sed -e "s/$ROW4_LABEL/$REPORT_ROW4/g" > $DAILY_REPORT
cat $DAILY_REPORT | sed -e "s/$ROW5_LABEL/$REPORT_ROW5/g" > $DAILY_REPORT.tmp
cat $DAILY_REPORT.tmp | sed -e "s/$ROW6_LABEL/$REPORT_ROW6/g" > $DAILY_REPORT
cat $DAILY_REPORT | sed -e "s/$ROW7_LABEL/$REPORT_ROW7/g" > $DAILY_REPORT.tmp

mv $DAILY_REPORT.tmp $DAILY_REPORT
#Clean up
#rm $OUTPUT_FILE


##Email Subject
#Daily Performance KPI Report
##Email Body
#The following is the performance aggregate at the 90th% for the past day ($START_DATE - $END_DATE).  
#To List
#DL-SH-UI-Unified <DL-SH-UI-Unified@corp.ebay.com>; Mcginnis, Dominic <rmcginnis@stubhub.com>
#CC List
#Jasso, Manuel <mjasso@stubhub.com>; Tanaka, Mike <mtanaka@stubhub.com>; Aidun, Rashid <raidun@ebay.com>


#mailx -s "Daily Performance KPI Report" -a "MIME-Version: 1.0" -a "Content-Type: text/html" "rmcginnis@stubhub.com" <  $DAILY_REPORT