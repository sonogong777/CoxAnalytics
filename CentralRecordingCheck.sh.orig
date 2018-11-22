#!/bin/bash
#SITE="SD"
SITE=$(crontab -l|grep SITE|awk '{print $6}'|awk -F"=" '{print $2}'|tr '[:lower:]' '[:upper:]')
DBSERVER="$1"
DATABASE="riodev"
DBPORT="3306"
DEBUG=0
DBCONN="memsql -sN -D riodev -u root -h $DBSERVER -P $DBPORT -e"
DAY0=`date +%Y-%m-%d`
DAY1=`date --date='1 days ago' +%Y-%m-%d`
DAY2=`date --date='2 days ago' +%Y-%m-%d`
DAY3=`date --date='3 days ago' +%Y-%m-%d`
DAY4=`date --date='4 days ago' +%Y-%m-%d`
DAY5=`date --date='5 days ago' +%Y-%m-%d`

#usage

if [ "$#" -gt 1 ];then
  echo
  echo "Usage: $0"
  echo "Memsql Report"
  exit
fi

#site information
echo "---------------"
printf "| SITE:  %3s  |\n" $SITE
echo "---------------"

#Scheduled yesterday
#totalScheduled=$(memsql -sN -D riodev -u root -h $DBSERVER -P $DBPORT -e "select count(*) from Recordings where ScheduledTime >= '$YESTERDAY' AND ScheduledTime < '$TODAY';")
totalScheduled=$($DBCONN "select count(*) from Recordings where ScheduledTime >= '$YESTERDAY' AND ScheduledTime < '$TODAY';")
printf  "\nScheduled yesterday\n Total Scheduled: "
printf "$totalScheduled\n"
printf " ELK query to be added\n\n"

#Recordings yesterday
totalRecordings=$($DBCONN "select count(*) from Recordings where StartTime >= '$YESTERDAY' AND StartTime < '$TODAY';")
totalFailedRec=$($DBCONN "select count(*) from Recordings where StartTime >= '$YESTERDAY' AND StartTime < '$TODAY' AND ( (StatSegmentsSuccess / (StatSegmentsSuccess + StatSegmentsFailure + StatSegmentsCompleteFailure) < .98) OR (StatSegmentsSuccess =0) );")

printf "Recordings yesterday\n Total Recording: "
printf "$totalRecordings\n"
printf " Total Recording Failure: $totalFailedRec\n\n"

#Accounts with recordings from yestaday
totalAccount=$($DBCONN "select count(distinct(AccountID)) from Recordings where StartTime >= '$YESTERDAY' AND StartTime < '$TODAY';")

printf "Accounts with recordings form yesterday\n Total Accounts: "
printf "$totalAccount\n\n"
