#!/bin/bash

options()
{
echo
echo " USE         : ./maint.sh {option}"
echo " options: -suspend, -resume, -view"
echo
}

view()
{
isi networks list pools -v | grep -i suspend
}

resume()
{
for sub in `isi networks list pool|egrep "Static|Dynamic"|grep -v enc-nas-mgt.ee.intern|awk '{print $1}'`
do
id=`isi_nodes -L %{id}`
pool=`isi networks list pool|grep $sub|awk '{print $2}'`
isi networks modify pool --name $sub:$pool --sc-resume-node=$id
done
}

suspend()
{
for sub in `isi networks list pool|egrep "Static|Dynamic"|grep -v enc-nas-mgt.ee.intern|awk '{print $1}'`
do
id=`isi_nodes -L %{id}`
pool=`isi networks list pool|grep $sub|awk '{print $2}'`
isi networks modify pool --name $sub:$pool --sc-suspend-node=$id
done
}

# Script Options

case $1 in
        -suspend) suspend;;
        -resume) resume;;
        -view) view;;
        *) options;;
esac
