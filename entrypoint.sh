#!/bin/bash
PROTO=$1
JOBS=$2
echo "called with: $@"

cd /opt/fuzz
while /bin/true; do
	./afl2influx.sh -i influx -p 8086 -d fuzzing out/$PROTO
	sleep 1
done &
afl-multicore -c $PROTO.conf start $JOBS
sleep infinity
