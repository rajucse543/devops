git clone --depth 1 --branch v19.08 https://gerrit.fd.io/r/vpp

#!bin/bash
cd $MEDIA/vpp
log INFO "Checking the VPP Status"
dpkg -l | grep vpp
dpkg -l | grep DPDK
log INFO"Making dep file"
make install-dep
log INFO "Building package"
make build
make pkg-deb
log INFO "Running"
make run 

