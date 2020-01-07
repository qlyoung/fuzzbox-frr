#!/bin/bash
PROTO=$1
JOBS=$2

cd /opt/fuzz
/usr/sbin/grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini > /dev/null 2>&1 & 
influxd run > /dev/null 2>&1 & 
while /bin/true; do
	./monitor.sh -i fuzzing out/$PROTO > /dev/null 2>&1
	sleep 1
done &
afl-multicore -c $PROTO.conf start $JOBS
bash
