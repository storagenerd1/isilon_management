#!/bin/bash
#
# This script is create to gather information about a Isilon cluster and output this in XML.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Storagenerd
#
# version: 20150908
#
# USAGE         : ./cg_get_info {option}
##

options()
{
echo
echo " USE         : ./cg_get_info {option}"
echo " options: -config, -config-usage"
echo
}

config-usage()
{
TMP=/tmp
TMPF=$TMP/diskusage.txt
TMPS=$TMP/snapusage.txt

isi quota list --no-header --no-footer --format csv | grep False | awk -F "," '{print $3,$8}'>>$TMPF
isi quota list --no-header --no-footer --format csv | grep True | awk -F "," '{print $3,$8}'>>$TMPS

cluster=`sudo isi stat -q | grep Name | awk '{print $3}'`
version=`sudo isi version | awk '{print $3}'`

printf "<CLUSTER NAME='$cluster' VERSION='$version'> \n"
for node in `sudo isi status -q | grep "%)|" | grep -v Totals | sed s/"|"/" "/g | awk '{print $1}'`
do
name=`sudo isi stat -n $node |egrep "Name"|awk '{print $3}'`
ip=`sudo isi stat -n $node |egrep "IP"|awk '{print $4}'`
sn=`sudo isi stat -n $node |egrep "SN"|awk '{print $3}'`
printf " <NODE ID='$node' NAME='$name' IP='$ip' SR='$sn' /> \n"
done
for cust in `cat $TMPF | awk '{print $1}' `
do
size=`grep $cust $TMPF|awk '{print $2}'`
printf " <FS NAME='$cust' SIZE='$size' />\n"
done
for snap in `cat $TMPS | awk '{print $1}' `
do
size=`grep $snap $TMPS|awk '{print $2}'`
printf " <SNAP FS NAME='$snap' SIZE='$size' />\n"
done
SIZE1=`df -k|grep OneFS|awk '{print $2}'`
SIZE2=`df -k|grep OneFS|awk '{print $3}'`
SIZE3=`df -k|grep OneFS|awk '{print $4}'`
printf " <POOLUSAGE>\n"
printf " <POOL NAME='OneFS' ID='01' SIZE='$SIZE1' USED='$SIZE2' AVAILABLE='$SIZE3' POTENTIAL='0'></POOL>\n"
printf " </POOLUSAGE>\n"
printf "</CLUSTER>
"
rm $TMPF
rm $TMPS
}

config()
{
cluster=`sudo isi stat -q | grep Name | awk '{print $3}'`
version=`sudo isi version | awk '{print $3}'`

printf "<CLUSTER NAME='$cluster' VERSION='$version'> \n"
for node in `sudo isi status -q | grep "%)|" | grep -v Totals | sed s/"|"/" "/g | awk '{print $1}'`
do
name=`sudo isi stat -n $node |egrep "Name"|awk '{print $3}'`
ip=`sudo isi stat -n $node |egrep "IP"|awk '{print $4}'`
sn=`sudo isi stat -n $node |egrep "SN"|awk '{print $3}'`
printf " <NODE ID='$node' NAME='$name' IP='$ip' SR='$sn' /> \n"
done
printf "</CLUSTER>
"

}

# Script Options

case $1 in
        -config) config;;
        -config-usage) config-usage;;
        *) options;;
esac
