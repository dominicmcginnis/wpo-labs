#!/bin/bash

OUTPUT_FILE="results.html"

REPORT_URL="http://srwv00dev059.stubcorp.dev:5000/superposed/display"

if [ "$1" != "" ]; then
	METRIC=$1;
else
	METRIC="90th%20Percentile";
fi

#SubRoutine to get the files and populate the reports 
function getData {

echo "Getting data for: ${START_DATE} - ${END_DATE}"

EVENT_TEST_PARAMS="step_1_label=unifiedEvent_cable_prod_RW&"\
"step_1_label=unifiedEvent_cable_prod_SLCD&"\
"step_1_label=unifiedEvent_cable_prod_EG&"\
"step_1_label=unifiedEvent_cable_prod_SF&"\
"step_1_label_hidden=unifiedEvent_cable_prod_RW%2CunifiedEvent_cable_prod_SLCD%2CunifiedEvent_cable_prod_EG%2CunifiedEvent_cable_prod_SF&"\
"step_1_start_ts=$START_DATE&step_1_end_ts=$END_DATE"

HP_TEST_PARAMS="step_2_label=unifiedHP_cable_prod_RW&"\
"step_2_label=unifiedHP_cable_prod_SLCD&"\
"step_2_label=unifiedHP_cable_prod_EG&"\
"step_2_label=unifiedHP_cable_prod_SF&"\
"step_2_label_hidden=unifiedHP_cable_prod_RW%2CunifiedHP_cable_prod_SLCD%2CunifiedHP_cable_prod_EG%2CunifiedHP_cable_prod_SF&"\
"step_2_start_ts=$START_DATE&step_2_end_ts=$END_DATE"

SEARCH_TEST_PARAMS="step_3_label=unifiedSearchResults_cable_prod_RW&"\
"step_3_label=unifiedSearchResults_cable_prod_SLCD&"\
"step_3_label=unifiedSearchResults_cable_prod_EG&"\
"step_3_label=unifiedSearchResults_cable_prod_SF&"\
"step_3_label_hidden=unifiedSearchResults_cable_prod_RW%2CunifiedSearchResults_cable_prod_SLCD%2CunifiedSearchResults_cable_prod_EG%2CunifiedSearchResults_cable_prod_SF&"\
"step_3_start_ts=$START_DATE&step_3_end_ts=$END_DATE"

TEAM_TEST_PARAMS="step_4_label=unifiedTeam_cable_prod_RW&"\
"step_4_label=unifiedTeam_cable_prod_SLCD&"\
"step_4_label=unifiedTeam_cable_prod_EG&"\
"step_4_label=unifiedTeam_cable_prod_SF&"\
"step_4_label_hidden=unifiedTeam_cable_prod_RW%2CunifiedTeam_cable_prod_SLCD%2CunifiedTeam_cable_prod_EG%2CunifiedTeam_cable_prod_SF&"\
"step_4_start_ts=$START_DATE&step_4_end_ts=$END_DATE"

ARTIST_TEST_PARAMS="step_5_label=unifiedArtist_cable_prod_RW&"\
"step_5_label=unifiedArtist_cable_prod_SLCD&"\
"step_5_label=unifiedArtist_cable_prod_EG&"\
"step_5_label=unifiedArtist_cable_prod_SF&"\
"step_5_label_hidden=unifiedArtist_cable_prod_RW%2CunifiedArtist_cable_prod_SLCD%2CunifiedArtist_cable_prod_EG%2CunifiedArtist_cable_prod_SF&"\
"step_5_start_ts=$START_DATE&step_5_end_ts=$END_DATE"

VENUE_TEST_PARAMS="step_6_label=unifiedVenue_cable_prod_RW&"\
"step_6_label=unifiedVenue_cable_prod_SLCD&"\
"step_6_label=unifiedVenue_cable_prod_EG&"\
"step_6_label=unifiedVenue_cable_prod_SF&"\
"step_6_label_hidden=unifiedVenue_cable_prod_RW%2CunifiedVenue_cable_prod_SLCD%2CunifiedVenue_cable_prod_EG%2CunifiedVenue_cable_prod_SF&"\
"step_6_start_ts=$START_DATE&step_6_end_ts=$END_DATE"

XO_LANDING_TEST_PARAMS="step_7_label=xo_newxo_cable_prod_SLCD&"\
"step_7_label=xo_newxo_cable_prod_EG&"\
"step_7_label=xo_newxo_cable_prod_SF&"\
"step_7_label_hidden=xo_newxo_cable_prod_SLCD%2Cxo_newxo_cable_prod_EG%2Cxo_newxo_cable_prod_SF&"\
"step_7_start_ts=$START_DATE&step_7_end_ts=$END_DATE"

NEW_HP_TEST_PARAMS="step_8_label=unifiedCardsHP_cable_prod_RW&"\
"step_8_label=unifiedCardsHP_cable_prod_SLCD&"\
"step_8_label=unifiedCardsHP_cable_prod_EG&"\
"step_8_label=unifiedCardsHP_cable_prod_SF&"\
"step_8_label_hidden=unifiedCardsHP_cable_prod_RW%2CunifiedCardsHP_cable_prod_SLCD%2CunifiedCardsHP_cable_prod_EG%2CunifiedCardsHP_cable_prod_SF&"\
"step_8_start_ts=$START_DATE&step_8_end_ts=$END_DATE"

URL_PARAMS="$EVENT_TEST_PARAMS&"\
"$HP_TEST_PARAMS&"\
"$SEARCH_TEST_PARAMS&"\
"$TEAM_TEST_PARAMS&"\
"$ARTIST_TEST_PARAMS&"\
"$VENUE_TEST_PARAMS&"\
"$XO_LANDING_TEST_PARAMS&"\
"$NEW_HP_TEST_PARAMS&"\
"chart=column&table=true&metric=$METRIC&timeFormat=s"


echo "Running: $REPORT_URL?$URL_PARAMS"

DATES_ROW="${DATES_ROW}<th colspan='2'><a href='$REPORT_URL?$URL_PARAMS'>$DATE_LABEL</a></th>"

curl -s "$REPORT_URL?$URL_PARAMS" > $OUTPUT_FILE

#Get the Full Page Time for all 7 tests
for j in "${ROWS[@]}";
do

	FPT_ROW_VALUE=`xmllint --xpath "//tbody/tr[$j]/td[2]/text()" --html $OUTPUT_FILE`
	UX_ROW_VALUE=`xmllint --xpath "//tbody/tr[$j]/td[3]/text()" --html $OUTPUT_FILE`
	if [ "$FPT_ROW_VALUE" == "0.0" ]; then
		FPT_ROW_VALUE=""
	fi
	if [ "$UX_ROW_VALUE" == "0.0" ]; then
		UX_ROW_VALUE=""
	fi

	case "$j" in
		1)
		REPORT_ROW1="${REPORT_ROW1}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
		;;
		2)
		REPORT_ROW2="${REPORT_ROW2}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
		;;
		3)
		REPORT_ROW3="${REPORT_ROW3}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
		;;
		4)
		REPORT_ROW4="${REPORT_ROW4}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
		;;
		5)
		REPORT_ROW5="${REPORT_ROW5}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
		;;
		6)
		REPORT_ROW6="${REPORT_ROW6}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
		;;
		7)
		REPORT_ROW7="${REPORT_ROW7}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
		;;
		8)
		REPORT_ROW8="${REPORT_ROW8}<td align='right'>${FPT_ROW_VALUE}</td><td align='right'>${UX_ROW_VALUE}</td>"
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
    echo "</tbody></table></div><div><p>For more information and a breakout by region visit: http://srwv00dev059.stubcorp.dev:5000/results/dashboard</p></div></body></html>" >> $DAILY_REPORT
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
		8)
		echo "${REPORT_ROW8}</tr>" >> $DAILY_REPORT
		;;
	esac
done
}

function sendReport {
	EMAIL_SUBJECT="Daily Performance KPI Report"
	TO_LIST="ooxenham@stubhub.com,kkrishnasamy@stubhub.com,kartchandrasekar@ebay.com,bkalra@stubhub.com,mjasso@stubhub.com,mtanaka@stubhub.com,rmcginnis@stubhub.com"
	CC_LIST="raidun@ebay.com,sveio@stubhub.com,Prapunja.Pokhrel@stubhub.com,zzhou2@ebay.com,bamccoy@stubhub.com,vgudi@stubhub.com,cchi@ebay.com,manilsson@stubhub.com,mghazizadeh@stubhub.com,mboos@stubhub.com"
	##Uncomment for testing	
	#`/root/email/send_email --subject "${EMAIL_SUBJECT}" --to "rmcginnis@stubhub.com" < ${DAILY_REPORT}`
	`/root/email/send_email --subject "${EMAIL_SUBJECT}" --to "${TO_LIST}" --cc "${CC_LIST}" < ${DAILY_REPORT}`
}

function cleanup {
	rm ${DAILY_REPORT}
}

#Define actual report names
REPORT_ROW1="<tr><td>Event Page</td>"
REPORT_ROW2="<tr><td>Simplified Home Page</td>"
REPORT_ROW3="<tr><td>Search Results Page</td>"
REPORT_ROW4="<tr><td>Team Page</td>"
REPORT_ROW5="<tr><td>Artist Page</td>"
REPORT_ROW6="<tr><td>Venue Page</td>"
REPORT_ROW7="<tr><td>XO Landing Page</td>"
REPORT_ROW8="<tr><td>Explore Home Page</td>"

ROWS=(1 2 3 4 5 6 7 8)

DATES_ROW='<th  width="340px"></th>'
HEADER_ROW="<th width='340px' class='left'>Label</th>"
TIME_LABEL=""

DAILY_REPORT="dailyReport_`date +%Y-%m-%d`.html"

# Build the begging of the report file
REPORT_SUBJECT="<div>The following is the performance aggregate report at the <b>90th Percentile over CABLE (5/1 Mbps 28ms RTT) speeds</b> for `date +%Y-%m-%d+00:00:00`.</div>"
echo "<html><head><style>table{border-collapse:collapse;border:1px solid #FF0000;}table th { border:1px solid #FF0000; }table td{border:1px solid #FF0000;}</style></head><body>${REPORT_SUBJECT}<br />" > $DAILY_REPORT

#Run for the required dates
DATES=(1 2 3 4 5 6 7)
#DATES=(1 2 3 4 5 6 7 30)
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
	TIME_LABEL="${TIME_LABEL}<th class='center'>Full Load Time (s)</th><th class='center'>User Ready Time (s)</th>"
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
cleanup
