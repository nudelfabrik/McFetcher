#!/bin/sh

# SETTINGS
# Minecraft Server directory
WDIR="/usr/local/share/minecraft-server/"
# User running the server
MCUSER="mcserver"
# uid of MCUSER
MCID=$(id -u $MCUSER)
# Command starting the server
MCSTART="service minecraft start"


cd $WDIR
echo "Getting Mojang Feed..."
wget --no-check-certificate https://mojang.com/feed/
DPATH=$(grep -o -m 1 \"https://s3.amazonaws.com/Minecraft.Download/versions/.\*.jar\" index.html | sed 's/\"//g')
FILE=$(echo $DPATH | grep -o minecraft_server.\*.jar)
if [ -s $FILE ]
then
    echo "No new Version available"
    exit 0
else
    echo "Downloading new Version"
    wget --no-check-certificate $DPATH
    echo "Stopping Server ..."
    sudo -u $MCUSER tmux send stop "Enter"
    sleep 10
    if [ -z "$(pgrep -u $MCID java)" ]
    then
        echo "Server is Down!"
        echo "Replace minecraft_server.jar"
        cp $FILE minecraft_server.jar
    else
        echo "Something is wrong!"
        echo "Minecraft still running!"
        exit 1
    fi
    echo "Starting Server"
    $MCSTART
    rm index.html
    exit 0

fi
