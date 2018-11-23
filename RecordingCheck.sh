#!/bin/bash 
#SITE="SD"
SITE=$(crontab -l|grep SITE|awk '{print $6}'|awk -F"=" '{print $2}'|tr '[:lower:]' '[:upper:]')
DBSERVER="$1"
DAYS=5
OUTPUT=$0.output.csv
DATABASE="riodev"
DBPORT="3306"
DEBUG=0
DBCONN="memsql -sN -D riodev -u root -h $DBSERVER -P $DBPORT -e"

#usage

if [ "$#" -gt 1 ];then
  echo
  echo "Usage: $0 <sql-master-ip>"
  echo "Memsql Recording Report"
  exit
fi

#set up the DAY 
for i in $(seq 0 $DAYS)
do 
  DAY[$i]=`date --date="$i days ago" +%Y-%m-%d`
done


#site information
#printf "%4s," $SITE


#main loop 
for i in $(seq $DAYS -1 1)
do
   echo -n "$SITE,${DAY[$i]},$SITE:Scheduled:"
   #schedules
   echo -n `$DBCONN "select count(*) from Recordings where ScheduledTime >= '${DAY[$i]}' AND ScheduledTime < '${DAY[$i-1]}' AND XRID like 'V%';"`
   echo -n ",$SITE:Recordings:"
   #Recording
   echo -n `$DBCONN "select count(*) from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND XRID like 'V%';"`
   echo -n ",$SITE:RecordingFailure:"
   #Recording Failure
   echo -n `$DBCONN "select count(*) from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND XRID like 'V%' AND ( (StatSegmentsSuccess / (StatSegmentsSuccess + StatSegmentsFailure + StatSegmentsCompleteFailure) < .98) OR (StatSegmentsSuccess =0) );"`
   echo -n ",$SITE:AccountWithRecording:"
   #Accounts with Recording
   echo `$DBCONN "select count(distinct(substring(AccountID,1,20))) as 'Accounts' from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND XRID like 'V%';"`
done

#printf "%4s,${DAY[1]}\n" $SITE
##Scheduled yesterday
##totalScheduled=$(memsql -sN -D riodev -u root -h $DBSERVER -P $DBPORT -e "select count(*) from Recordings where ScheduledTime >= '${DAY[1]}' AND ScheduledTime < '${DAY[0]}';"
#totalScheduled=$($DBCONN "select count(*) from Recordings where ScheduledTime >= '${DAY[1]}' AND ScheduledTime < '${DAY[0]}' AND XRID like 'V%';")
#printf "%4s,$totalScheduled,\n" $SITE
#
##Recordings yesterday
##totalRecordings=$($DBCONN "select count(*) from Recordings where StartTime >= '${DAY[1]}' AND StartTime < '${DAY[0]}';")
#totalRecordings=$($DBCONN "select count(*) from Recordings where StartTime >= '${DAY[1]}' AND StartTime < '${DAY[0]}' AND XRID like 'V%';")
##totalFailedRec=$($DBCONN "select count(*) from Recordings where StartTime >= '${DAY[1]}' AND StartTime < '${DAY[0]}' AND ( (StatSegmentsSuccess / (StatSegmentsSuccess + StatSegmentsFailure + StatSegmentsCompleteFailure) < .98) OR (StatSegmentsSuccess =0) );")
#totalFailedRec=$($DBCONN "select count(*) from Recordings where StartTime >= '${DAY[1]}' AND StartTime < '${DAY[0]}' AND XRID like 'V%' AND ( (StatSegmentsSuccess / (StatSegmentsSuccess + StatSegmentsFailure + StatSegmentsCompleteFailure) < .98) OR (StatSegmentsSuccess =0) );")
#
#printf "%4s,$totalRecordings,\n" $SITE
#printf "%4s,$totalFailedRec,\n" $SITE
#
##Accounts with recordings from yestaday
##totalAccount=$($DBCONN "select count(distinct(AccountID)) from Recordings where StartTime >= '${DAY[1]}' AND StartTime < '${DAY[0]}';")
#totalAccount=$($DBCONN "select count(distinct(substring(AccountID,1,20))) as 'Accounts' from Recordings where StartTime >= '${DAY[1]}' AND StartTime < '${DAY[0]}' AND XRID like 'V%';")
#
#printf "%4s,$totalAccount\n" $SITE
