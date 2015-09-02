#!/bin/bash

#Setup inbound variables
CL_ARGS=( "$@" )

METRIC=""
KEYNOTE_API_KEY=""
SEND_REPORT="false"
GNERATE_REPORT="true"

for arg in "${CL_ARGS[@]}"; do
	if [[ "$arg" =~ .*--metric=.* ]]; then
		METRIC="${arg:9}"
	fi
    if [[ "$arg" =~ .*--keynoteAPIKey=.* ]]; then
            KEYNOTE_API_KEY="${arg:16}"
    fi
	if [[ "$arg" =~ .*--sendMail=.* ]]; then
		SEND_REPORT="${arg:11}"
	fi
	if [[ "$arg" =~ .*--generateReport=.* ]]; then
		GNERATE_REPORT="${arg:17}"
	fi
done

if [ "$METRIC" == "" ]; then
	METRIC="90th%20Percentile"
fi

function fetchSplunkData {
	echo "fetching splunk data"
}

function fetchKeyNoteData {
	KEYNOTE_PAGE="$1"

	if [ "$KEYNOTE_API_KEY" != "" ]; then
		KEYNOTE_OUTPUT_FILE="keynote.xml"
		TEST_SLOT_ID="1513700"
		HOME_PAGE_TRANS_ID="1513700:1"
		SEARCH_PAGE_TRANS_ID="1513700:2"
		EVENT_PAGE_TRANS_ID="1513700:3"
		API_URL="https://api.keynote.com/keynote/api/getgraphdata?api_key=$KEYNOTE_API_KEY"
		API_URI="&slotidlist=$TEST_SLOT_ID&timemode=absolute&absolutetimestart=$KEYNOTE_START_DATE&absolutetimeend=$KEYNOTE_END_DATE&averagemethod=PERCSTAT&percentile=90&bucket=86400&format=xml&pagecomponent=T"

		if [ "$KEYNOTE_PAGE" == "HOME" ]; then
			#Fetch UK Homepage data
			API_URI="$API_URI&transpagelist=$HOME_PAGE_TRANS_ID"
			API_URL="$API_URL$API_URI"
			curl -s "$API_URL" > $KEYNOTE_OUTPUT_FILE
			echo `xmllint --xpath "string(//graph_data/measurement/graph_option/data_cell[@name='avg_perf']/@value)" $KEYNOTE_OUTPUT_FILE`
			rm $KEYNOTE_OUTPUT_FILE
		elif [ "$KEYNOTE_PAGE" == "EVENT" ]; then
			#Fetch UK Event data
			API_URI="$API_URI&transpagelist=$EVENT_PAGE_TRANS_ID"
			API_URL="$API_URL$API_URI"
			curl -s "$API_URL" > $KEYNOTE_OUTPUT_FILE
			echo `xmllint --xpath "string(//graph_data/measurement/graph_option/data_cell[@name='avg_perf']/@value)" $KEYNOTE_OUTPUT_FILE`
			rm $KEYNOTE_OUTPUT_FILE
		elif [ "$KEYNOTE_PAGE" == "SEARCH" ]; then
			#Fetch UK Search data
			API_URI="$API_URI&transpagelist=$SEARCH_PAGE_TRANS_ID"
			API_URL="$API_URL$API_URI"
			curl -s "$API_URL" > $KEYNOTE_OUTPUT_FILE
			echo `xmllint --xpath "string(//graph_data/measurement/graph_option/data_cell[@name='avg_perf']/@value)" $KEYNOTE_OUTPUT_FILE`
			rm $KEYNOTE_OUTPUT_FILE
		fi
	fi
}

function getGoal {
	ROW="$1"
	TYPE="$2"

	if [ "$TYPE" == "Ads" ]; then
		echo "n/a"
		return
	fi

	case "${ROW}" in
		0)
		#Site Speed Goal
		if [ "$TYPE" == "UX" ]; then
			echo "3.8"
		elif [ "$TYPE" == "FPT" ]; then
			echo "5.6"
		fi
		;;
		1)
		#Event Page
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "6.5"
		fi
		;;
		2)
		#HOME Page
		if [ "$TYPE" == "UX" ]; then
			echo "3.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "5.5"
		fi
		;;
		3)
		#Search Page
		if [ "$TYPE" == "UX" ]; then
			echo "3.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "5.5"
		fi
		;;
		4)
		#Team Page
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "6.5"
		fi
		;;
		5)
		#Artist Page
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "6.5"
		fi
		;;
		6)
		#Venue Page
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "6.5"
		fi
		;;
		7)
		#XO Page
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "5.5"
		fi
		;;
		8)
		#Category Page
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "6.5"
		fi
		;;
		9)
		#Grouping Page
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "6.5"
		fi
		;;
		10)
		#UK mWeb Home Page
		if [ "$TYPE" == "UX" ]; then
			echo "n/a"
		elif [ "$TYPE" == "FPT" ]; then
			echo "5.5"
		fi
		;;
		11)
		#UK mWeb Search Page
		if [ "$TYPE" == "UX" ]; then
			echo "n/a"
		elif [ "$TYPE" == "FPT" ]; then
			echo "0.20"
		fi
		;;
		12)
		#UK mWeb Event Page
		if [ "$TYPE" == "UX" ]; then
			echo "n/a"
		elif [ "$TYPE" == "FPT" ]; then
			echo "5.5"
		fi
		;;
		13)
		#US Submit Order API
		if [ "$TYPE" == "UX" ]; then
			echo "4.0"
		elif [ "$TYPE" == "FPT" ]; then
			echo "4.0"
		fi
		;;
		14)
		#UK Submit Order API
		if [ "$TYPE" == "UX" ]; then
			echo "n/a"
		elif [ "$TYPE" == "FPT" ]; then
			echo "4.0"
		fi
		;;
	esac
}

#SubRoutine to get the files and populate the reports 
function getData {

	echo "Getting data for: ${START_DATE} - ${END_DATE}"

EVENT_TEST_PARAMS="step_1_label=unifiedEvent_cable_prod_SLCD&"\
"step_1_label=unifiedEvent_cable_prod_EAST&"\
"step_1_label=unifiedEvent_cable_prod_SF&"\
"step_1_label_hidden=unifiedEvent_cable_prod_SLCD%2CunifiedEvent_cable_prod_EAST%2CunifiedEvent_cable_prod_SF&"\
"step_1_start_ts=$START_DATE&step_1_end_ts=$END_DATE"

NEW_HP_TEST_PARAMS="step_2_label=unifiedCardsHP_cable_prod_SLCD&"\
"step_2_label=unifiedCardsHP_cable_prod_EAST&"\
"step_2_label=unifiedCardsHP_cable_prod_SF&"\
"step_2_label_hidden=unifiedCardsHP_cable_prod_SLCD%2CunifiedCardsHP_cable_prod_EAST%2CunifiedCardsHP_cable_prod_SF&"\
"step_2_start_ts=$START_DATE&step_2_end_ts=$END_DATE"

SEARCH_TEST_PARAMS="step_3_label=unifiedSearchResults_cable_prod_SLCD&"\
"step_3_label=unifiedSearchResults_cable_prod_EAST&"\
"step_3_label=unifiedSearchResults_cable_prod_SF&"\
"step_3_label_hidden=unifiedSearchResults_cable_prod_SLCD%2CunifiedSearchResults_cable_prod_EAST%2CunifiedSearchResults_cable_prod_SF&"\
"step_3_start_ts=$START_DATE&step_3_end_ts=$END_DATE"

TEAM_TEST_PARAMS="step_4_label=unifiedTeam_cable_prod_SLCD&"\
"step_4_label=unifiedTeam_cable_prod_EAST&"\
"step_4_label=unifiedTeam_cable_prod_SF&"\
"step_4_label_hidden=unifiedTeam_cable_prod_SLCD%2CunifiedTeam_cable_prod_EAST%2CunifiedTeam_cable_prod_SF&"\
"step_4_start_ts=$START_DATE&step_4_end_ts=$END_DATE"

ARTIST_TEST_PARAMS="step_5_label=unifiedArtist_cable_prod_SLCD&"\
"step_5_label=unifiedArtist_cable_prod_EAST&"\
"step_5_label=unifiedArtist_cable_prod_SF&"\
"step_5_label_hidden=unifiedArtist_cable_prod_SLCD%2CunifiedArtist_cable_prod_EAST%2CunifiedArtist_cable_prod_SF&"\
"step_5_start_ts=$START_DATE&step_5_end_ts=$END_DATE"

VENUE_TEST_PARAMS="step_6_label=unifiedVenue_cable_prod_SLCD&"\
"step_6_label=unifiedVenue_cable_prod_EAST&"\
"step_6_label=unifiedVenue_cable_prod_SF&"\
"step_6_label_hidden=unifiedVenue_cable_prod_SLCD%2CunifiedVenue_cable_prod_EAST%2CunifiedVenue_cable_prod_SF&"\
"step_6_start_ts=$START_DATE&step_6_end_ts=$END_DATE"

XO_LANDING_TEST_PARAMS="step_7_label=xo_newxo_cable_prod_SLCD&"\
"step_7_label=xo_newxo_cable_prod_EAST&"\
"step_7_label=xo_newxo_cable_prod_SF&"\
"step_7_label_hidden=xo_newxo_cable_prod_SLCD%2Cxo_newxo_cable_prod_EAST%2Cxo_newxo_cable_prod_SF&"\
"step_7_start_ts=$START_DATE&step_7_end_ts=$END_DATE"

CATEGORY_TEST_PARAMS="step_8_label=unifiedCategory_cable_prod_SLCD&"\
"step_8_label=unifiedCategory_cable_prod_EAST&"\
"step_8_label=unifiedCategory_cable_prod_SF&"\
"step_8_label_hidden=unifiedCategory_cable_prod_SLCD%2CunifiedCategory_cable_prod_EAST%2CunifiedCategory_cable_prod_SF&"\
"step_8_start_ts=$START_DATE&step_8_end_ts=$END_DATE"

GROUPING_TEST_PARAMS="step_9_label=unifiedGrouping_cable_prod_SLCD&"\
"step_9_label=unifiedGrouping_cable_prod_EAST&"\
"step_9_label=unifiedGrouping_cable_prod_SF&"\
"step_9_label_hidden=unifiedGrouping_cable_prod_SLCD%2CunifiedGrouping_cable_prod_EAST%2CunifiedGrouping_cable_prod_SF&"\
"step_9_start_ts=$START_DATE&step_9_end_ts=$END_DATE"

URL_PARAMS="$EVENT_TEST_PARAMS&"\
"$NEW_HP_TEST_PARAMS&"\
"$SEARCH_TEST_PARAMS&"\
"$TEAM_TEST_PARAMS&"\
"$ARTIST_TEST_PARAMS&"\
"$VENUE_TEST_PARAMS&"\
"$XO_LANDING_TEST_PARAMS&"\
"$CATEGORY_TEST_PARAMS&"\
"$GROUPING_TEST_PARAMS&"\
"chart=column&table=true&metric=$METRIC&timeFormat=s"


echo "Running: $REPORT_URL?$URL_PARAMS"

DATES_ROW="${DATES_ROW}<th colspan='5'><a href='$REPORT_URL?$URL_PARAMS'>$DATE_LABEL</a></th>"

curl -s "$REPORT_URL?$URL_PARAMS" > $OUTPUT_FILE

#US SPEED INDEX FORMULA:
#(SubmitOrderAPI*0.2)+(HP*0.1)+(EP*0.25)+(SRP*0.1)+(XO*0.2)+(ARTIST*0.05)+(TEAM*0.05)+(VEN*0.05)
#UK SPEED INDEX FORMULA:
#(SubmitOrderAPI*0.3)+(HP*0.15)+(EP*0.40)+(SRP*0.15)
US_SPEED_FPT_INDEX=0
US_SPEED_UX_INDEX=0
UK_SPEED_FPT_INDEX=0

#Get the Full Page Time for all tests
for j in "${ROWS[@]}";
do
	FPT_ROW_VALUE="0.0"
	UX_ROW_VALUE="0.0"
	ADS_ROW_VALUE="0.0"
	FPT_PRC_DEV_VALUE=""
	UX_PRC_DEV_VALUE=""
	FPT_CELL_COLOR="transparent"
	UX_CELL_COLOR="transparent"
	SPEED_INDEX_MODIFIER=0

	if (( $(bc <<< "${j} < 10") == 1 )); then
		FPT_ROW_VALUE=`xmllint --xpath "//tbody/tr[$j]/td[2]/text()" --html $OUTPUT_FILE`
		UX_ROW_VALUE=`xmllint --xpath "//tbody/tr[$j]/td[3]/text()" --html $OUTPUT_FILE`
		ADS_ROW_VALUE=`xmllint --xpath "//tbody/tr[$j]/td[21]/text()" --html $OUTPUT_FILE`
	elif (( $(bc <<< "${j} > 9") == 1 && $(bc <<< "${j} < 13") == 1 )); then
		case "$j" in
			10)
				KEY_PAGE="HOME"
			;;
			11)
				KEY_PAGE="SEARCH"
			;;
			12)
				KEY_PAGE="EVENT"
			;;
		esac
		echo "********Running Keynote report for: $KEY_PAGE"
		FPT_ROW_VALUE="$(fetchKeyNoteData ${KEY_PAGE})"
		UX_ROW_VALUE="n/a"
		UX_PRC_DEV_VALUE="n/a"
	else
		case "$j" in
			13)
				COUNTRY="US"
			;;
			14)
				COUNTRY="UK"
			;;
		esac
		fetchSplunkData ${COUNTRY}
	fi


	if [ "$FPT_ROW_VALUE" != "n/a" ]; then
		if [ "$FPT_ROW_VALUE" == "0.0" ]; then
			FPT_ROW_VALUE=""
		elif (( $(bc <<< "${FPT_ROW_VALUE} > 0") == 1 )); then
			#statements
			GOAL_VAL=$(getGoal ${j} FPT)
			FPT_PRC_DEV_VALUE="$(printf %.0f $(bc -l <<< "scale=2; ((1 / ${FPT_ROW_VALUE}) / (1 / ${GOAL_VAL})) * 100" ))"
			if (( $(bc <<< "${FPT_PRC_DEV_VALUE} > 99") )); then
				FPT_CELL_COLOR="#3CB371"
			elif (( $(bc <<< "${FPT_PRC_DEV_VALUE} >= 90") )); then
				FPT_CELL_COLOR="#FFFF00"
			elif (( $(bc <<< "${FPT_PRC_DEV_VALUE} < 90") )); then
				FPT_CELL_COLOR="#FF6347"
			fi
			FPT_PRC_DEV_VALUE="${FPT_PRC_DEV_VALUE}%"
		fi
	fi	

	if [ "$UX_ROW_VALUE" != "n/a" ]; then
		if [ "$UX_ROW_VALUE" == "0.0" ]; then
			UX_ROW_VALUE=""
		elif (( $(bc <<< "${UX_ROW_VALUE} > 0") == 1 )); then
			#statements
			GOAL_VAL=$(getGoal ${j} UX)
			UX_PRC_DEV_VALUE="$(printf %.0f $(bc -l <<< "scale=2; ((1 / ${UX_ROW_VALUE}) / (1 / ${GOAL_VAL})) * 100" ))"
			if (( $(bc <<< "${UX_PRC_DEV_VALUE} > 99") )); then
				UX_CELL_COLOR="#3CB371"
			elif (( $(bc <<< "${UX_PRC_DEV_VALUE} >= 90") )); then
				UX_CELL_COLOR="#FFFF00"
			elif (( $(bc <<< "${UX_PRC_DEV_VALUE} < 90") )); then
				UX_CELL_COLOR="#FF6347"
			fi
			UX_PRC_DEV_VALUE="${UX_PRC_DEV_VALUE}%"
		fi 
	fi

	if [ "$ADS_ROW_VALUE" != "n/a" ]; then
		if [ "$ADS_ROW_VALUE" == "0.0" ]; then
			ADS_ROW_VALUE=""
		fi
	fi

	case "$j" in
		1)
		#Event Page
		SPEED_INDEX_MODIFIER=0.25
		REPORT_ROW1="${REPORT_ROW1}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		2)
		#Home Page
		SPEED_INDEX_MODIFIER=0.1
		REPORT_ROW2="${REPORT_ROW2}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		3)
		#Search Page
		SPEED_INDEX_MODIFIER=0.1
		REPORT_ROW3="${REPORT_ROW3}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		4)
		#Team Page
		SPEED_INDEX_MODIFIER=0.05
		REPORT_ROW4="${REPORT_ROW4}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		5)
		#Artist Page
		SPEED_INDEX_MODIFIER=0.05
		REPORT_ROW5="${REPORT_ROW5}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		6)
		#Venue Page
		SPEED_INDEX_MODIFIER=0.05
		REPORT_ROW6="${REPORT_ROW6}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		7)
		#XO Landing Page
		SPEED_INDEX_MODIFIER=0.2
		REPORT_ROW7="${REPORT_ROW7}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		8)
		#Cat Page
		REPORT_ROW8="${REPORT_ROW8}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		9)
		#Gropup Page
		REPORT_ROW9="${REPORT_ROW9}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		10)
		#UK Home Page
		SPEED_INDEX_MODIFIER=0.15
		REPORT_ROW10="${REPORT_ROW10}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		11)
		#UK Search Page
		SPEED_INDEX_MODIFIER=0.15
		REPORT_ROW11="${REPORT_ROW11}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		12)
		#UK Event Page
		SPEED_INDEX_MODIFIER=0.40
		REPORT_ROW12="${REPORT_ROW12}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		13)
		#UK Event Page
		SPEED_INDEX_MODIFIER=0.20
		REPORT_ROW13="${REPORT_ROW13}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
		14)
		#UK Event Page
		SPEED_INDEX_MODIFIER=0.30
		REPORT_ROW14="${REPORT_ROW14}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_ROW_VALUE}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_ROW_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td><td align='right'>${ADS_ROW_VALUE}</td>"
		;;
	esac
	if (( $(bc <<< "${j} < 8") == 1 )); then
		if [[ "$FPT_ROW_VALUE" != "n/a" && "$FPT_ROW_VALUE" != "0.0" && "$FPT_ROW_VALUE" != "" ]]; then
			echo "****  calulating US FPT speed index: ${FPT_ROW_VALUE} and ${SPEED_INDEX_MODIFIER}"
			US_SPEED_FPT_INDEX=$(bc -l <<< "scale=2; ${US_SPEED_FPT_INDEX} + (${FPT_ROW_VALUE} * ${SPEED_INDEX_MODIFIER})")
		fi
		if [[ "$UX_ROW_VALUE" != "n/a" && "$UX_ROW_VALUE" != "0.0" && "$UX_ROW_VALUE" != "" ]]; then
			echo "****  calulating US UX speed index: ${UX_ROW_VALUE} and ${SPEED_INDEX_MODIFIER}"
			US_SPEED_UX_INDEX=$(bc -l <<< "scale=2; ${US_SPEED_UX_INDEX} + (${UX_ROW_VALUE} * ${SPEED_INDEX_MODIFIER})")
		fi
	elif (( $(bc <<< "${j} > 9") == 1 && $(bc <<< "${j} < 13") == 1)); then
		if [[ "$FPT_ROW_VALUE" != "n/a" && "$FPT_ROW_VALUE" != "0.0" && "$FPT_ROW_VALUE" != "" ]]; then
			echo "****  calulating UK speed index: ${FPT_ROW_VALUE} and ${SPEED_INDEX_MODIFIER}"
			UK_SPEED_FPT_INDEX=$(bc -l <<< "scale=2; ${UK_SPEED_FPT_INDEX} + (${FPT_ROW_VALUE} * ${SPEED_INDEX_MODIFIER})" )
		fi
	fi	
done

#Setup Site Speed values
FPT_SITE_SPEED_VAL=$(bc -l <<< "scale=2; (${US_SPEED_FPT_INDEX} * 0.98) + (${UK_SPEED_FPT_INDEX} * 0.02)")
UX_SITE_SPEED_VAL="${US_SPEED_UX_INDEX}"
FPT_PRC_DEV_VALUE=""
UX_PRC_DEV_VALUE=""
if (( $(bc <<< "${FPT_SITE_SPEED_VAL} > 0") == 1 )); then
	#statements
	GOAL_VAL=$(getGoal 0 FPT)
	FPT_PRC_DEV_VALUE="$(printf %.0f $(bc -l <<< "scale=2; ((1 / ${FPT_SITE_SPEED_VAL}) / (1 / ${GOAL_VAL})) * 100" ))"
	if (( $(bc <<< "${FPT_PRC_DEV_VALUE} > 99") )); then
		FPT_CELL_COLOR="#3CB371"
	elif (( $(bc <<< "${FPT_PRC_DEV_VALUE} >= 90") )); then
		FPT_CELL_COLOR="#FFFF00"
	elif (( $(bc <<< "${FPT_PRC_DEV_VALUE} < 90") )); then
		FPT_CELL_COLOR="#FF6347"
	fi
	FPT_PRC_DEV_VALUE="${FPT_PRC_DEV_VALUE}%"
fi

if (( $(bc <<< "${UX_SITE_SPEED_VAL} > 0") == 1 )); then
	#statements
	GOAL_VAL=$(getGoal 0 UX)
	UX_PRC_DEV_VALUE="$(printf %.0f $(bc -l <<< "scale=2; ((1 / ${UX_SITE_SPEED_VAL}) / (1 / ${GOAL_VAL})) * 100" ))"
	if (( $(bc <<< "${UX_PRC_DEV_VALUE} > 99") )); then
		UX_CELL_COLOR="#3CB371"
	elif (( $(bc <<< "${UX_PRC_DEV_VALUE} >= 90") )); then
		UX_CELL_COLOR="#FFFF00"
	elif (( $(bc <<< "${UX_PRC_DEV_VALUE} < 90") )); then
		UX_CELL_COLOR="#FF6347"
	fi
	UX_PRC_DEV_VALUE="${UX_PRC_DEV_VALUE}%"
fi 

SITE_SPEED_INDEX_ROW="${SITE_SPEED_INDEX_ROW}<td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_SITE_SPEED_VAL}</td><td style='background-color: ${FPT_CELL_COLOR}' align='right'>${FPT_PRC_DEV_VALUE}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_SITE_SPEED_VAL}</td><td style='background-color: ${UX_CELL_COLOR}' align='right'>${UX_PRC_DEV_VALUE}</td>"

#Clean up
rm $OUTPUT_FILE
}

function beginTable {
	echo "<div id='summary-table'><table class='display' id='stats_table'><thead><tr>${DATES_ROW}</tr><tr>${HEADER_ROW}${TIME_LABEL_ROW}</tr><tr>${DEVIATION_LABEL_ROW}</tr></thead><tbody>" >> $DAILY_REPORT
}

function finalizeReport {
    echo "</tbody></table></div><div><p>* UK mWeb times supplied by Keynote - non-UX Time</p></div><div><p>** Sumbit Order API times supplied by Splunk</p></div><div><p>*** Ads Time is the total time from when the Ads are initialized till the last Ad finishes displaying.</p></div><div><table><tr><td style='font-weight: bold'>Color Codes:</td><td style='background-color: #3CB371'>GREEN &gt; 99% of Goal</td><td style='background-color: #FFFF00'>YELLOW 90% - 99% of Goal</td><td style='background-color: #FF6347'>RED &lt; 90% of Goal</td></tr></table></div><div><p>For more information and a breakout by region visit: <a href='http://slcv024.stubcorp.com:5000/results/dashboard'>HARStorage Dashboard</a></p></div></body></html>" >> $DAILY_REPORT
}

function populateSummaryRow {
	echo "${BREAK_ROW}" >> $DAILY_REPORT
	echo "${SITE_SPEED_INDEX_ROW}</tr>" >> $DAILY_REPORT
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
		9)
		echo "${REPORT_ROW9}</tr>" >> $DAILY_REPORT
		;;
		10)
		echo "${REPORT_ROW10}</tr>" >> $DAILY_REPORT
		;;
		11)
		echo "${REPORT_ROW11}</tr>" >> $DAILY_REPORT
		;;
		12)
		echo "${REPORT_ROW12}</tr>" >> $DAILY_REPORT
		;;
		13)
		echo "${REPORT_ROW13}</tr>" >> $DAILY_REPORT
		;;
		14)
		echo "${REPORT_ROW14}</tr>" >> $DAILY_REPORT
		;;
	esac
done
#populateSummaryRow
}

function sendReport {
	EMAIL_SUBJECT="Daily Performance KPI Report"
	TO_LIST="ooxenham@stubhub.com,kkrishnasamy@stubhub.com,kartchandrasekar@ebay.com,bkalra@stubhub.com,mjasso@stubhub.com,mtanaka@stubhub.com,rmcginnis@stubhub.com,raidun@ebay.com,sveio@stubhub.com,Prapunja.Pokhrel@stubhub.com,zzhou2@ebay.com,bamccoy@stubhub.com,cchi@ebay.com,manilsson@stubhub.com,mboos@stubhub.com,gvasvani@stubhub.com,ldanckwerth@stubhub.com,sewang@paypal.com,sshivakumar@stubhub.com,pavaish@stubhub.com,olemmers@stubhub.com,hetashah@ebay.com,tady@stubhub.com,smalladi@stubhub.com,chro@stubhub.com"
	##Uncomment for testing	
	#`/root/email/send_email --subject "${EMAIL_SUBJECT}" --to "rmcginnis@stubhub.com" < ${HARSTORAGE_FS_LOCATION}/dailyReport.html`
	`/root/email/send_email --subject "${EMAIL_SUBJECT}" --to "${TO_LIST}" < ${HARSTORAGE_FS_LOCATION}/dailyReport.html`
}

function copyReportToHarStorage {
	cp ${DAILY_REPORT} ${HARSTORAGE_FS_LOCATION}/dailyReport.html
}

function cleanup {
	rm ${DAILY_REPORT}
}

function populateLabelsAndGoals {
	#Define actual report names
	REPORT_ROW1="<tr><td style='overflow: hidden; white-space: nowrap;'>Event Page</td><td colspan='2' align='right'>$(getGoal 1 FPT)</td><td colspan='2' align='right'>$(getGoal 1 UX)</td><td colspan='1' align='right'>$(getGoal 1 Ads)</td>"
	REPORT_ROW2="<tr><td style='overflow: hidden; white-space: nowrap;'>Explore Home Page</td><td colspan='2' align='right'>$(getGoal 2 FPT)</td><td colspan='2' align='right'>$(getGoal 2 UX)</td><td colspan='1' align='right'>$(getGoal 2 Ads)</td>"
	REPORT_ROW3="<tr><td style='overflow: hidden; white-space: nowrap;'>Search Results Page</td><td colspan='2' align='right'>$(getGoal 3 FPT)</td><td colspan='2' align='right'>$(getGoal 3 UX)</td><td colspan='1' align='right'>$(getGoal 3 Ads)</td>"
	REPORT_ROW4="<tr><td style='overflow: hidden; white-space: nowrap;'>Team Page</td><td colspan='2' align='right'>$(getGoal 4 FPT)</td><td colspan='2' align='right'>$(getGoal 4 UX)</td><td colspan='1' align='right'>$(getGoal 4 Ads)</td>"
	REPORT_ROW5="<tr><td style='overflow: hidden; white-space: nowrap;'>Artist Page</td><td colspan='2' align='right'>$(getGoal 5 FPT)</td><td colspan='2' align='right'>$(getGoal 5 UX)</td><td colspan='1' align='right'>$(getGoal 5 Ads)</td>"
	REPORT_ROW6="<tr><td style='overflow: hidden; white-space: nowrap;'>Venue Page</td><td colspan='2' align='right'>$(getGoal 6 FPT)</td><td colspan='2' align='right'>$(getGoal 6 UX)</td><td colspan='1' align='right'>$(getGoal 6 Ads)</td>"
	REPORT_ROW7="<tr><td style='overflow: hidden; white-space: nowrap;'>XO Landing Page</td><td colspan='2' align='right'>$(getGoal 7 FPT)</td><td colspan='2' align='right'>$(getGoal 7 UX)</td><td colspan='1' align='right'>$(getGoal 7 Ads)</td>"
	REPORT_ROW8="<tr><td style='overflow: hidden; white-space: nowrap;'>Category Page</td><td colspan='2' align='right'>$(getGoal 8 FPT)</td><td colspan='2' align='right'>$(getGoal 8 UX)</td><td colspan='1' align='right'>$(getGoal 8 Ads)</td>"
	REPORT_ROW9="<tr><td style='overflow: hidden; white-space: nowrap;'>Grouping Page</td><td colspan='2' align='right'>$(getGoal 9 FPT)</td><td colspan='2' align='right'>$(getGoal 9 UX)</td><td colspan='1' align='right'>$(getGoal 9 Ads)</td>"	
	REPORT_ROW10="<tr><td style='overflow: hidden; white-space: nowrap;'>UK mWeb Home<b>*</b></td><td colspan='2' align='right'>$(getGoal 10 FPT)</td><td colspan='2' align='right'>$(getGoal 10 UX)</td><td colspan='1' align='right'>$(getGoal 10 Ads)</td>"	
	REPORT_ROW11="<tr><td style='overflow: hidden; white-space: nowrap;'>UK mWeb Search<b>*</b></td><td colspan='2' align='right'>$(getGoal 11 FPT)</td><td colspan='2' align='right'>$(getGoal 11 UX)</td><td colspan='1' align='right'>$(getGoal 11 Ads)</td>"	
	REPORT_ROW12="<tr><td style='overflow: hidden; white-space: nowrap;'>UK mWeb Event<b>*</b></td><td colspan='2' align='right'>$(getGoal 12 FPT)</td><td colspan='2' align='right'>$(getGoal 12 UX)</td><td colspan='1' align='right'>$(getGoal 12 Ads)</td>"	
	REPORT_ROW13="<tr><td style='overflow: hidden; white-space: nowrap;'>US Submit Order API<b>**</b></td><td colspan='2' align='right'>$(getGoal 13 FPT)</td><td colspan='2' align='right'>$(getGoal 13 UX)</td><td colspan='1' align='right'>$(getGoal 13 Ads)</td>"	
	REPORT_ROW14="<tr><td style='overflow: hidden; white-space: nowrap;'>UK Submit Order API<b>**</b></td><td colspan='2' align='right'>$(getGoal 14 FPT)</td><td colspan='2' align='right'>$(getGoal 14 UX)</td><td colspan='1' align='right'>$(getGoal 14 Ads)</td>"	
	
	SITE_SPEED_INDEX_ROW="<tr><td style='font-weight: bold'>Site Speed Index</td><td colspan='2' align='right'>$(getGoal 0 FPT)</td><td colspan='2' align='right'>$(getGoal 0 UX)</td><td colspan='1' align='right'>$(getGoal 0 Ads)</td>"	
}

HARSTORAGE_FS_LOCATION="/opt/harstorage-1.0/harstorage/templates"

if [[ "${GNERATE_REPORT}" == "true" ]]; then
	#Begin setup
	OUTPUT_FILE="results.html"
	REPORT_URL="http://slcv024.stubcorp.com:5000/superposed/display"

	populateLabelsAndGoals

	ROWS=(1 2 3 4 5 6 7 8 9 10 11 12 13 14)
	#Run for the required dates
	DATES=(1 2 3 4 5 6 7 15 30)
	#DATES=(15)

	DATES_ROW="<th colspan='1' width='340px'></th><th colspan='5'></th>"
	HEADER_ROW="<th colspan='1' width='340px' class='left'></th><th colspan='5'>GOALS</th>"
	TIME_LABEL_ROW=""
	DEVIATION_LABEL_ROW="<th colspan='1' width='340px' class='left'>Label</th><th class='center' colspan='2'>Full Load Time (s)</th><th class='center' colspan='2'>User Ready Time (s)</th><th class='center' colspan='1'>Ads Time (s)</th>"

	DAILY_REPORT="dailyReport_`date +%Y-%m-%d`.html"

	# Build the begging of the report file
	REPORT_SUBJECT="<div>The following is the performance aggregate report at the <b>90th Percentile over CABLE (5/1 Mbps 28ms RTT) speeds for `date +%Y-%m-%d+00:00:00`</b>.</div><div>To view this report on the web click here: <a href='http://slcv024.stubcorp.com:5000/results/dailyReport'>Daily Report</a></div>"
	echo "<html><head><style>table{border-collapse:collapse;border:1px solid #FF0000;}table th { background-color: #D3D3D3; border:1px solid #FF0000; }table td{border:1px solid #FF0000;}</style></head><body>${REPORT_SUBJECT}<br />" > $DAILY_REPORT

	DATES_LEN="$(bc <<< "(${#DATES[@]}*4)+5")"
	BREAK_ROW="<tr style='background-color: #D3D3D3;'><td colspan='${DATES_LEN}'></td></tr>"

	#Run Reports
	for i in "${DATES[@]}"; 
	do
		echo "i = $i"
		START_DAYS_BACK=$i
		if [ "$i" == "15" ]; then
			END_DAYS_BACK=0
			DATE_LABEL='Last 15 Days'
		elif [ "$i" == "30" ]; then
			END_DAYS_BACK=0
			DATE_LABEL='Last 30 Days'
		else
			let END_DAYS_BACK=$START_DAYS_BACK-1
			#DATE_LABEL=`date -v-${END_DAYS_BACK}d +%Y-%m-%d`
			DATE_LABEL=`date -d "${END_DAYS_BACK} days ago" +%Y-%m-%d`
		fi
		TIME_LABEL_ROW="${TIME_LABEL_ROW}<th colspan='2' class='center'>Full Load Time (s)</th><th colspan='2' class='center'>User Ready Time (s)</th><th colspan='1' class='center'>Ads Time (s)</th>"
		DEVIATION_LABEL_ROW="${DEVIATION_LABEL_ROW}<th colspan='1' class='center'>Actual</th><th colspan='1' class='center'>% of Goal</th><th colspan='1' class='center'>Actual</th><th colspan='1' class='center'>% of Goal</th><th colspan='1' class='center'>Actual</th>"

		START_DATE=`date -d "${START_DAYS_BACK} days ago" +%Y-%m-%d+00:00:00`	
		END_DATE=`date -d "${END_DAYS_BACK} days ago" +%Y-%m-%d+00:00:00`
		KEYNOTE_START_DATE=`date -d "${START_DAYS_BACK} days ago" "+%Y-%b-%d 00:00 AM"`	
		KEYNOTE_START_DATE="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$KEYNOTE_START_DATE")"

		KEYNOTE_END_DATE=`date -d "${END_DAYS_BACK} days ago" "+%Y-%b-%d 00:00 AM"`
		KEYNOTE_END_DATE="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$KEYNOTE_END_DATE")"

		getData
	done

	#Finalize document, send report and clenaup
	beginTable
	populateTable
	finalizeReport
	copyReportToHarStorage
	cleanup
fi
if [[ "${SEND_REPORT}" == "true" ]]; then
	sendReport
fi
