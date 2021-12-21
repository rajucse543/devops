log INFO "Installing Lua Package"
sudo apt-get install lua
tar -xvzf $MEDIA/
cd 
make
sudo ./app/pktgen -l 0-4 -n 3 -- -P -m "[1:3].0"



 curl -R -O http://www.lua.org/ftp/lua-5.3.2.tar.gz
 
 cd /usr/local/src/lua-5.3.2