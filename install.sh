#!/bin/bash

if [ -e /docker/assembly.tar.gz ]; then
    echo "- - - - - - - - - - - - - - - - - -"
    echo "Install Assembly"
    echo "- - - - - - - - - - - - - - - - - -"
    cd /opt/karaf
    tar --strip-components=1 -C /opt/karaf -xzvf /docker/assembly.tar.gz
    echo "- - - - - - - - - - - - - - - - - -"
    cp -rv /docker/profiles/initial/* /opt/karaf/
    if [ -d /docker/profiles/custom-initial ]; then
       cp -rv /docker/profiles/custom-initial/* /opt/karaf/
    fi
    rm /docker/assembly.tar.gz
fi

echo "====================================="
echo "Deploy Bundles"
echo "====================================="
cd /opt/karaf
#rm -r data/cache/*
#rm data/log/*
#rm -r saved_deploy
mkdir saved_deploy
mv deploy/* saved_deploy/
echo "-------------------------------------"
echo "Start karaf in background"
echo "-------------------------------------"
./bin/start
sleep 2
(tail -f data/log/karaf.log) &
sleep 10
while [ "$(grep -c Done data/log/karaf.log)" = "0" ]; do
    echo "."
    sleep 5
done

cnt=1

while [ -e /docker/deploy/deploy${cnt}.gogo ]; do
    echo "-------------------------------------"
    echo "Deploy file deploy${cnt}.gogo"
    echo "-------------------------------------"
    cat /docker/deploy/deploy${cnt}.gogo
    echo "-------------------------------------"
    cat /docker/deploy/deploy${cnt}.gogo | ./bin/client
    echo "-------------------------------------"
    echo "DEPLOY FINISHED"
    echo "-------------------------------------"
    
    sleep 10
    
    echo "-------------------------------------"
    echo "Actual Features"
    echo "-------------------------------------"
    echo list | ./bin/client

    let cnt=${cnt}+1
done

echo "-------------------------------------"
echo "Deploy blueprints"
echo "-------------------------------------"
mv saved_deploy/* deploy/
rm -r saved_deploy
sleep 10

echo "-------------------------------------"
echo "Actual Features"
echo "-------------------------------------"
echo list | ./bin/client

echo "-------------------------------------"
echo "Stop karaf"
echo "-------------------------------------"
./bin/stop
sleep 5
cnt=0
while [ "$(ps -f|grep java|grep karaf|grep -v grep|grep -c .)" = "1" ]; do
    echo "."
    sleep 5
    let cnt=$cnt+1
    if [ $cnt -gt 30 ]; then
        killall -9 java
        sleep 2
        break
    fi
done

echo "====================================="
echo "Finished"
echo "====================================="
