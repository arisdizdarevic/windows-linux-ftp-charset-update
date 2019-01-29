#!/bin/bash

######################################################################################################
#
# Script to check pure-ftpd log file for PUT files and if needed change their encoding
# Author: Aris Dizdarevic (aris.dizdarevic@gmail.com)
# v11.01.2019
#
# INSTALL
#
# Upload script to system:
# /usr/sbin/ftp-charsetd.sh
#
# on CentOS create file:
# /usr/lib/systemd/system/ftp-charsetd.service
#
###############################
#
# [Unit]
# Description=Ftp-charset change daemon
# After=multi-user.target
#
# [Service]
# Type=simple
# User=root
# ExecStart=/usr/sbin/ftp-charsetd.sh
# WorkingDirectory=/tmp
# Restart=on-failure
#
# [Install]
# WantedBy=multi-user.target
#
################################
#
# After that run:
# systemctl daemon-reload
# systemctl start ftp-charsetd.service
# systemctl enable ftp-charsetd.service
#
# Upon problem dos -> unix convert
# /bin/bash^M: bad interpreter: No such file or directory
#
# run:
# sed -i -e 's/\r$//' /usr/sbin/ftp-charsetd.sh
#
######################################################################################################

GAP=20                                                  #How long to wait in seconds for checking
LOGFILE='/var/log/pureftpd.log'                         #File to read FTP upload log files from
CHARFROM=WINDOWS-1250                                   #Chacter from
CHARTO='UTF8'                                   	    #Charset to 
LOGTOFILE='/var/log/pure-ftpd-correct-charset.log'	    #File to post any charset changes to

if ps ax | grep $0 | grep -v $$ | grep bash | grep -v grep
then
    echo "The daemon is already running."
    exit 1
fi

#If logfile does not exist create it
if [ ! -f $LOGTOFILE ]; then
 touch "$LOGTOFILE"
fi

echo_time_log() {
    echo `date +'%b %e %R '` "$@"
}

#Get current long of the file
len=`wc -l $LOGFILE | awk '{ print $1 }'`
echo_time_log "PureFTPD change charset daemon started... Current pureFTPD log: $len lines." >> "$LOGTOFILE"

while :
do
    if [ -N $LOGFILE ]; then

        newlen=`wc -l $LOGFILE | awk ' { print $1 }'`
        newlines=`expr $newlen - $len`
        OUTPUT="$(tail -$newlines $LOGFILE)"

        while read -r line; do

                if [[ $line == *"PUT"* ]]; then
                        TL2=${line//\"/:}
                        TL3=${TL2%:*}
                        TL4=${TL3##*:}
                        TL5=${TL4:4}
                        TL5=${TL5//%20/ }

                        REZ="$(file -i "$TL5")"

                        if [[ $REZ == *"unknown-8bit"* ]]; then
                                echo_time_log "$TL5 converted charset $CHARFROM -> $CHARTO" >> "$LOGTOFILE"

                                KONV="$(iconv -f $CHARFROM -t $CHARTO "$TL5")"
                                echo "$KONV" > "$TL5"
                                fi
                        fi
        done <<< "$OUTPUT"

        #tail -$newlines $LOGFILE
        len=$newlen
    fi
sleep $GAP
done
exit 0
