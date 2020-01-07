fuzzbox-frr
-----------

Docker box for fuzzing FRRouting with AFL

About
-----
This is a docker box with the following:

- LLVM 9
- `AFL`, built from source against LLVM 9
- `afl-utils`
- InfluxDB
- Grafana
- FRRouting

Grafana is hooked up to InfluxDB and polls it for information on current
fuzzing jobs.  This information is pushed into InfluxDB by tool that runs under
`afl-cron`. Grafana then serves as the monitoring platform for your
backgrounded AFL jobs.

Usage
-----
./run-docker.sh <daemon> <jobs>

E.g.
```
./run-docker.sh zebra 6
```

A host volume is used to mount the container's `/opt`, which contains all
content specific to this container. Fuzzing results are in
`/opt/fuzz/out/<daemon>`. Within the container, the easiest way to collect results is:

```
cd /opt/fuzz
afl-collect out/<daemon> results -- /usr/lib/frr/<daemon>
```

The path to the volume on the host is printed by `run-docker.sh`.
