#!/bin/bash

OUTPUT_FILE="results.html"

REPORT_URL="http://srwv00dev059.stubcorp.dev:5000/superposed/display"

#SubRoutine to get the files and populate the reports 
function getData {

echo "Getting data for: ${START_DATE} - ${END_DATE}"

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

DATES_ROW="${DATES_ROW}<th><a href='$REPORT_URL?$URL_PARAMS'>$DATE_LABEL</a></th>"

curl -s "$REPORT_URL?$URL_PARAMS" > $OUTPUT_FILE

#Get the Full Page Time for all 7 tests
for j in "${ROWS[@]}";
do

	ROW_VALUE=`xmllint --xpath "//tbody/tr[$j]/td[2]/text()" --html $OUTPUT_FILE`
	case "$j" in
		1)
		REPORT_ROW1="${REPORT_ROW1}<td align='right'>${ROW_VALUE}</td>"
		;;
		2)
		REPORT_ROW2="${REPORT_ROW2}<td align='right'>${ROW_VALUE}</td>"
		;;
		3)
		REPORT_ROW3="${REPORT_ROW3}<td align='right'>${ROW_VALUE}</td>"
		;;
		4)
		REPORT_ROW4="${REPORT_ROW4}<td align='right'>${ROW_VALUE}</td>"
		;;
		5)
		REPORT_ROW5="${REPORT_ROW5}<td align='right'>${ROW_VALUE}</td>"
		;;
		6)
		REPORT_ROW6="${REPORT_ROW6}<td align='right'>${ROW_VALUE}</td>"
		;;
		7)
		REPORT_ROW7="${REPORT_ROW7}<td align='right'>${ROW_VALUE}</td>"
		;;
	esac
done

#Clean up
rm $OUTPUT_FILE
}

function beginTable {
	echo "<div id='summary-table'><table class='display' id='stats_table'><thead><tr>${DATES_ROW}</tr><tr>${HEADER_ROW}${TIME_LABEL}</tr></thead><tbody>" >> $DAILY_REPORT
}

function finalizeReport {
	echo "</tbody></table></div></body></html>" >> $DAILY_REPORT
}

function populateTable {
for x in "${ROWS[@]}";
do
	case "$x" in
		1)
		echo "${REPORT_ROW1}</tr>" >> $DAILY_REPORT
		;;
		2)
		echo "${REPORT_ROW2}</tr>" >> $DAILY_REPORT
		;;
		3)
		echo "${REPORT_ROW3}</tr>" >> $DAILY_REPORT
		;;
		4)
		echo "${REPORT_ROW4}</tr>" >> $DAILY_REPORT
		;;
		5)
		echo "${REPORT_ROW5}</tr>" >> $DAILY_REPORT
		;;
		6)
		echo "${REPORT_ROW6}</tr>" >> $DAILY_REPORT
		;;
		7)
		echo "${REPORT_ROW7}</tr>" >> $DAILY_REPORT
		;;
	esac
done
}

function sendReport {
	EMAIL_SUBJECT="Daily Performance KPI Report"
	EMAIL_BODY="The following is the performance aggregate report at the 90th% for `date +%Y-%m-%d+00:00:00`."
#	TO_LIST="rmcginnis@stubhub.com"
	TO_LIST="DL-SH-UI-Unified@corp.ebay.com, rmcginnis@stubhub.com, raidun@ebay.com"
	`/root/email/send_email --subject "${EMAIL_SUBJECT}" --to ${TO_LIST} < ${DAILY_REPORT}`
}

#Define actual report names
REPORT_ROW1="<tr><td>Event Page</td>"
REPORT_ROW2="<tr><td>Home Page</td>"
REPORT_ROW3="<tr><td>Search Results Page</td>"
REPORT_ROW4="<tr><td>Team Page</td>"
REPORT_ROW5="<tr><td>Artist Page</td>"
REPORT_ROW6="<tr><td>Venue Page</td>"
REPORT_ROW7="<tr><td>XO Landing Page</td>"

ROWS=(1 2 3 4 5 6 7)

DATES_ROW='<th width="340px"></th>'
HEADER_ROW="<th width='340px' class='left'>Label</th>"
TIME_LABEL=""

DAILY_REPORT="dailyReport_`date +%Y-%m-%d`.html"

# Build the begging of the report file
REPORT_SUBJECT="<div>The following is the performance aggregate report at the 90th% for `date +%Y-%m-%d+00:00:00`.</div>"
echo "<html><head><style>table{border-collapse:collapse;border:1px solid #FF0000;}table th { border:1px solid #FF0000; }table td{border:1px solid #FF0000;}</style></head><body>${REPORT_SUBJECT}<br />" > $DAILY_REPORT

#Run for the required dates
DATES=(1 2 3 4 5 6 7 30)
#DATES=(1 2)
for i in "${DATES[@]}"; 
do
	echo "i = $i"
	START_DAYS_BACK=$i
	if [ "$i" == "30" ]; then
		END_DAYS_BACK=0
		DATE_LABEL='Last 30 Days'
	else
		let END_DAYS_BACK=$START_DAYS_BACK-1
		#DATE_LABEL=`date -v-${END_DAYS_BACK}d +%Y-%m-%d`
		DATE_LABEL=`date -d "${END_DAYS_BACK} days ago" +%Y-%m-%d`
	fi
	TIME_LABEL="${TIME_LABEL}<th class='center'>Full Load Time (ms)</th>"
	#START_DATE=`date -v-${START_DAYS_BACK}d +%Y-%m-%d+00:00:00`	
	#END_DATE=`date -v-${END_DAYS_BACK}d +%Y-%m-%d+00:00:00`
	START_DATE=`date -d "${START_DAYS_BACK} days ago" +%Y-%m-%d+00:00:00`	
	END_DATE=`date -d "${END_DAYS_BACK} days ago" +%Y-%m-%d+00:00:00`

	getData
done

beginTable
populateTable
finalizeReport
sendReport