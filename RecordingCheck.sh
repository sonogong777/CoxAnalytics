#!/bin/bash 
#SITE="SD"
SITE=$(crontab -l|grep SITE|awk '{print $6}'|awk -F"=" '{print $2}'|tr '[:lower:]' '[:upper:]')
DBSERVER="$1"
DAYS=7
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
echo -n "$SITE,Description"
for i in $(seq $DAYS -1 1)
do
  echo -n ",${DAY[$i]}"
done
echo ""

echo -n "$SITE,Scheduled"
for i in $(seq $DAYS -1 1)
do
  echo -n ",`$DBCONN "select count(*) from Recordings where ScheduledTime >= '${DAY[$i]}' AND ScheduledTime < '${DAY[$i-1]}' AND XRID like 'V%';"`"
done
echo ""

echo -n "$SITE,Recordings"
for i in $(seq $DAYS -1 1)
do
  echo -n ",`$DBCONN "select count(*) from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND (ErasedTime = 0 OR ErasedTime > StartTime) AND XRID like 'V%';"`"
done
echo ""

echo -n "$SITE,RecordingFailure"
for i in $(seq $DAYS -1 1)
do
  echo -n ",`$DBCONN "select count(*) from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND (ErasedTime = 0 OR ErasedTime > StartTime) AND XRID like 'V%' AND ( (StatSegmentsSuccess / (StatSegmentsSuccess + StatSegmentsFailure + StatSegmentsCompleteFailure) < .98) OR (StatSegmentsSuccess =0) );"`"
done
echo ""

echo -n "$SITE,AccountWithRecording"
for i in $(seq $DAYS -1 1)
do
  echo -n ",`$DBCONN "select count(distinct(substring(AccountID,1,20))) as 'Accounts' from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND XRID like 'V%';"`"
done
echo ""

