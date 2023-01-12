#!/usr/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
#                                                                                #  
##################################################################################

source /etc/functions.sh
source /etc/yiimpool.conf

sudo mkdir -p $STORAGE_ROOT/yiimp/yiimp_setup/tmp
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
echo -e "$GREEN => Additional System Files Completed  <= $COL_RESET"

echo
echo -e "$YELLOW => Building Berkeley 4.8, this may take several minutes <= $COL_RESET"
sudo mkdir -p $STORAGE_ROOT/berkeley/db4/
cd $STORAGE_ROOT/berkeley/db4/
hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
hide_output sudo tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db4/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-4.8.30.NC.tar.gz db-4.8.30.NC
echo
echo -e "$GREEN => Berkeley 4.8 Completed <= $COL_RESET"
echo

echo -e "$YELLOW => Building Berkeley 5.1, this may take several minutes <= $COL_RESET"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db5/
cd $STORAGE_ROOT/berkeley/db5/
hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-5.1.29.tar.gz'
hide_output sudo tar -xzvf db-5.1.29.tar.gz
cd db-5.1.29/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db5/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.1.29.tar.gz db-5.1.29
echo -e "$GREEN => Berkeley 5.1 Completed <= $COL_RESET"
echo
echo -e "$YELLOW => Building Berkeley 5.3, this may take several minutes <= $COL_RESET"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db5.3/
cd $STORAGE_ROOT/berkeley/db5.3/
hide_output sudo wget 'http://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz'
hide_output sudo tar -xzvf db-5.3.28.tar.gz
cd db-5.3.28/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db5.3/
hide_output sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.3.28.tar.gz db-5.3.28
echo -e "$GREEN => Berkeley 5.3 Completed <= $COL_RESET"
echo
echo -e "$YELLOW => Building OpenSSL 1.0.2g, this may take several minutes <= $COL_RESET"
echo
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
hide_output sudo wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2g.tar.gz --no-check-certificate
hide_output sudo tar -xf openssl-1.0.2g.tar.gz
cd openssl-1.0.2g
hide_output sudo ./config --prefix=$STORAGE_ROOT/openssl --openssldir=$STORAGE_ROOT/openssl shared zlib
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r openssl-1.0.2g.tar.gz openssl-1.0.2g
echo -e "$GREEN =>OpenSSL 1.0.2g Completed <= $COL_RESET"
echo

echo -e "$YELLOW => Building bls-signatures, this may take several minutes <= $COL_RESET"
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
hide_output sudo wget 'https://github.com/codablock/bls-signatures/archive/v20181101.zip'
hide_output sudo unzip v20181101.zip
cd bls-signatures-20181101
hide_output sudo cmake .
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r v20181101.zip bls-signatures-20181101
echo
echo -e "$GREEN => bls-signatures Completed$COL_RESET"

echo
echo -e "$YELLOW => Building blocknotify.sh <= $COL_RESET"
if [[ ("$wireguard" == "true") ]]; then
  source $STORAGE_ROOT/yiimp/.wireguard.conf
  echo '#####################################
  # Created by Afiniel for Yiimpool use...  #
  ###########################################
  #!/bin/bash
  blocknotify '""''"${DBInternalIP}"''""':$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
  sudo chmod +x /usr/bin/blocknotify.sh
else
  echo '#####################################
  # Created by Afiniel for Yiimpool use...  #
  ###########################################
  #!/bin/bash
  blocknotify 127.0.0.1:$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
  sudo chmod +x /usr/bin/blocknotify.sh
fi

echo
echo -e "$GREEN Daemon setup completed $COL_RESET"

set +eu +o pipefail
cd $HOME/yiimp_install_script/yiimp_single

echo -e "$CYAN => Installing daemonbuilder $COL_RESET"
cd $HOME/yiimp_install_script/daemon_builder
sudo cp -r $HOME/yiimp_install_script/daemon_builder/* $STORAGE_ROOT/daemon_builder

# Enable DaemonBuilder
echo '
#!/usr/bin/env bash
source /etc/yiimpool.conf
source /etc/functions.sh
cd $STORAGE_ROOT/daemon_builder
bash start.sh
cd ~
' | sudo -E tee /usr/bin/daemonbuilder >/dev/null 2>&1

# Set permissions
sudo chmod +x /usr/bin/daemonbuilder
echo -e "$GREEN Done...$COL_RESET"

echo '#!/bin/sh
USERSERVER='"${whoami}"'
PATH_STRATUM='"${path_stratum}"'
FUNCTION_FILE='"${FUNCTIONFILE}"'
VERSION='"${TAG}"'
BTCDEP='"${BTCDEP}"'
LTCDEP='"${LTCDEP}"'
ETHDEP='"${ETHDEP}"'
DOGEDEP='"${DOGEDEP}"''| sudo -E tee $STORAGE_ROOT/daemon_builder/conf/info.sh >/dev/null 2>&1
hide_output sudo chmod +x $STORAGE_ROOT/daemon_builder/conf/info.sh


cd $HOME/yiimp_install_script/yiimp_single