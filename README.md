Script to check pure-ftpd (or any other FTP-server) log file for PUT files and if needed change their encoding.

It is a way of solving problem if you use Windows (with ASCII encoding) - charset for example windows-1250, windows-1252... and then try to upload this "text" files over FTP to linux (in this example centOS).

Instead of clean convertion ASCII - UTF-8 files get charset=unknown-8bit and if viewing or editing that file in linux characters ščćž become something else.

This script converts text files with charset=unknown-8bit to utf-8

-----------------------------------------------------
Author: Aris Dizdarevic (aris.dizdarevic@gmail.com)
v11.01.2019
-----------------------------------------------------

---------------------INSTALL-------------------------

Upload script to system:
/usr/sbin/ftp-charsetd.sh

on CentOS create file:
/usr/lib/systemd/system/ftp-charsetd.service

-----------------Content of a file:-------------------
 [Unit]
 Description=Ftp-charset change daemon
 After=multi-user.target

 [Service]
 Type=simple
 User=root
 ExecStart=/usr/sbin/ftp-charsetd.sh
 WorkingDirectory=/tmp
 Restart=on-failure

 [Install]
 WantedBy=multi-user.target
-------------------------------------------------------

-----------------After that run:-----------------------
systemctl daemon-reload
systemctl start ftp-charsetd.service
systemctl enable ftp-charsetd.service
