#!/bin/env bash

#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by Afiniel for yiimpool use...
#####################################################

source /etc/functions.sh

RESULT=$(dialog --stdout --nocancel --default-item 1 --title "Yiimpool Menu v0.5.4" --menu "Choose one" -1 60 16 \
' ' "- Install Yiimp  -" \
1 "YiiMP Single Server" \
' ' "- Daemon Wallet Builder -" \
2 "Daemonbuilder" \
' ' "- NOT DONE! Upgrade stratum server -" \
3 "Yiimp stratum update " \
4 Exit)
if [ $RESULT = ] 
then
bash $(basename $0) && exit;
fi

if [ $RESULT = 1 ]
then
clear;
cd $HOME/yiimp_install_script/yiimp_single
source start.sh;
fi

if [ $RESULT = 2 ]
then
clear;
cd $HOME/yiimp_install_script/daemon_builder
source start.sh;
fi

if [ $RESULT = 3 ]
then
clear;
echo "This is not done yet, please come back later! Use yiimpool command again to start again.";
exit;
fi

if [ $RESULT = 4 ]
then
clear;
exit;
fi