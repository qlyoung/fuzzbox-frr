FROM qlyoung/fuzzbox:master

# frr & libyang build deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      git \
      build-essential \
      cgroup-bin \
      git autoconf automake libtool make libreadline-dev texinfo \    
      pkg-config libpam0g-dev libjson-c-dev bison flex python3-pytest \    
      libc-ares-dev python3-dev libsystemd-dev python-ipaddress python3-sphinx \    
      install-info build-essential libsystemd-dev libsnmp-dev perl libcap-dev \    
      cmake libpcre3-dev autoconf automake

# Install scripts & corpuses
RUN mkdir -p /opt/build
COPY ./frr-fuzz/install-frr.sh /opt/build/

# FRR build and install
RUN cd /opt/build && \
    # libyang build
    git clone https://github.com/CESNET/libyang.git && \
    cd libyang && \
    mkdir build; cd build && \
    cmake -DENABLE_LYD_PRIV=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr -D CMAKE_BUILD_TYPE:String="Release" .. && \
    make; make install && \
    cd /opt/build && \
    # FRR users and groups
    groupadd -r -g 92 frr && \
    groupadd -r -g 85 frrvty && \
    adduser --system --ingroup frr --home /var/run/frr/ --gecos "FRR suite" --shell /sbin/nologin frr && \
    usermod -a -G frrvty frr && \
    # FRR build
    git clone --single-branch --branch fuzz https://github.com/qlyoung/frr.git && \
    ./install-frr.sh -boiqaf

RUN mkdir -p /opt/fuzz/samples /opt/fuzz/out
COPY ./*.conf ./frr-fuzz/monitor.sh /opt/fuzz/
COPY ./frr-fuzz/samples /opt/fuzz/samples/

# Grafana
EXPOSE 3000
# InfluxDB
EXPOSE 8086

COPY ./entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["zebra", "6"]
