#!/bin/bash
#
# cDVR Recording Report.
# Synamedia - krhee@synamedia.com
#
#
VERSION=0.1
LIST="cox-memsql-list"
DATE=`date +%Y%m%d`
TMPOUT="$0.$DATE.tmp"
CSVOUT="$0.$DATE.csv"
LOGFILE="$0.log"

exec >  >(tee -ia $LOGFILE)
exec 2> >(tee -ia $LOGFILE >&2)

echo "`date +%Y%m%d%H%M`: START $0 Script"
if [ ! -f $LIST ];then 
   echo "Server list file $LIST not found" >> $LOGFILE
   exit 1
fi

#main loop 
for i in `cat $LIST|awk '{print $1}'`
do
  #check ssh key 
  if [ ! -f ../CoxKey/$i ];then
     echo "Key file $i not found" >> $LOGFILE
     exit 1
  fi

  #scp and execute script.
  scp -i ../CoxKey/$i -q root@$i:/root/report/*.csv report/
#  ssh -i ../CoxKey/$i -q root@$i ./RecordingCheck.sh $i

done > $TMPOUT

echo "Data capture complete, creating csv file"

##sort by site name
#site=($(cat $TMPOUT|awk -F"," '{print $1}'|sort|uniq))
#grep Descr $TMPOUT|head -1|cut -d, -f2-|xargs printf ",%s\n" > $CSVOUT
#
#for site in ${site[*]}
#do
#  grep $site $TMPOUT|grep -v Desc
#done >> $CSVOUT

#clean up tempfile
#rm -rf $TMPOUT
mv $TMPOUT backup/

echo "`date +%Y%m%d%H%M`: $0 COMPLETE" 
