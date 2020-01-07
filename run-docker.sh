#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

PROTO=$1
CORES=$2

docker build .
VOL=$(docker volume create)
VOLDETAILS=$(docker volume inspect $VOL)

# Setup AFL system settings
swapoff -a
echo core >/proc/sys/kernel/core_pattern
bash -c 'cd /sys/devices/system/cpu; echo performance | tee cpu*/cpufreq/scaling_governor'

printf "Results are saved in the container filesystem.\n"
printf "Container /opt filesystem details: %s\n" $VOLDETAILS
sleep 1

docker run -it -p 3000:3000 -p 8086:8086 --mount source=$VOL,target=/opt `docker images -q | head -n 1` $PROTO $CORES
