#!/bin/bash -x
#
# cDVR Recording Report.
# Synamedia - krhee@synamedia.com
#
#
LIST="cox-memsql-list"
DATE=`date +%Y%m%d`
TMPOUT="$0.$DATE.tmp"
TMPOUT2="$0.$DATE.tmp2"
CSVOUT="$0.$DATE.csv"

#main loop 
#for i in `cat $LIST`
#do 
#  scp -i $i -q RecordingCheck.sh root@$i:/root/
#  ssh -i $i -q root@$i ./RecordingCheck.sh $i
#done > $TMPOUT

site=($(cat $TMPOUT|awk -F"," '{print $1}'|sort|uniq))
max=$(($(cat $TMPOUT |head -1|grep -o ,|wc -l)+1))

for site in ${site[*]}
do
  for ((i=2; i<="$max"; i++))
  do
    grep $site $TMPOUT|cut -f"$i" -d,|paste -s -d, -
  done  
done > $CSVOUT

