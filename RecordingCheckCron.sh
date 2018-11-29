#!/bin/bash
#SITE="SD"
#Single day report for daily accumulation.
TIME=`date +%Y-%m-%d`
SITE=$(crontab -l|grep SITE|awk '{print $6}'|awk -F"=" '{print $2}'|tr '[:lower:]' '[:upper:]')
DBSERVER="$1"
DAYS=1
OUTPUT="report/$SITE.$TIME.output.csv"
DATABASE="riodev"
DBPORT="3306"
DEBUG=0
DBCONN="memsql -sN -D riodev -u root -h $DBSERVER -P $DBPORT -e"
LOGFILE="log/$0.log"

exec >  >(tee -ia $LOGFILE)
exec 2> >(tee -ia $LOGFILE >&2)

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
i=$DAYS

#main loop
main(){

echo -n "$SITE,Description"
  echo -n ",${DAY[$i]}"
echo ""

echo -n "$SITE,Scheduled"
  echo -n ",`$DBCONN "select count(*) from Recordings where ScheduledTime >= '${DAY[$i]}' AND ScheduledTime < '${DAY[$i-1]}' AND XRID like 'V%';"`"
echo ""

echo -n "$SITE,Recordings"
  echo -n ",`$DBCONN "select count(*) from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND XRID like 'V%';"`"
echo ""

echo -n "$SITE,RecordingFailure"
  echo -n ",`$DBCONN "select count(*) from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND XRID like 'V%' AND ( (StatSegmentsSuccess / (StatSegmentsSuccess + StatSegmentsFailure + StatSegmentsCompleteFailure) < .98) OR (StatSegmentsSuccess =0) );"`"
echo ""

echo -n "$SITE,AccountWithRecording"
  echo -n ",`$DBCONN "select count(distinct(substring(AccountID,1,20))) as 'Accounts' from Recordings where StartTime >= '${DAY[$i]}' AND StartTime < '${DAY[$i-1]}' AND XRID like 'V%';"`"
echo ""
}
main > $OUTPUT
