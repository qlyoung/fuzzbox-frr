#!/bin/bash
PROTO=$1
JOBS=$2
echo "called with: $@"

cd /opt/fuzz

afl-multicore -s 1 -v -c $PROTO.conf start $JOBS

# health check indicator
touch started

# Loop on pushing out stats
while /bin/true; do
	./afl2influx.sh -i influx -p 8086 -d fuzzing out/$PROTO
	sleep 1
done
