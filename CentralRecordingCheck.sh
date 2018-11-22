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
cat $TMPOUT|sort -k1 > $TMPOUT2
for site in ${site[*]}
do
  grep $site $TMPOUT|awk -F',' '{ for (i=1; i<=NF; i++) RtoC[i]= (RtoC[i]? RtoC[i] FS $i: $i) } END{ for (i in RtoC) print RtoC[i] }'
done > $CSVOUT

