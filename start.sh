#!/bin/bash

# prepare karaf

cd /opt/karaf
rm instances/instance.properties 

# custom environment

cd /opt/karaf
if [ ! "x$PREVENT_ENVIRONMENT" == "x1" ]; then
    if [  -e /docker/environment_custom.sh ]; then
      /docker/environment_custom.sh
    fi
fi

# load environment from files

if [ "x$SECRETS_DIRECTORY" != "x" ]; then
  for f in $SECRETS_DIRECTORY/* ; do
    if [ -f "$f" ]; then
      n=ENV_$(basename $f|tr . _|tr '[a-z]' '[A-Z]')
      echo "--- Read secret into $n"
      cat $f | read $n
    fi
  done
fi  

# copy profile

if [ "x$CONFIG_PROFILE" == "x" ]; then
  CONFIG_PROFILE=default
fi
if [ -e /docker/profiles/${CONFIG_PROFILE} ]; then
  echo "--- Copy profile ${CONFIG_PROFILE} to /opt/karaf"
  cp -rv /docker/profiles/${CONFIG_PROFILE}/* /opt/karaf/
fi

# substitute

IFS=$'\n' read -d '' -r -a folders < /docker/environment_folders.txt

for folder in "${folders[@]}"; do
#    echo $folder
    for file in $folder/*; do
        if [ -f $file ]; then
            echo "--- Substitute $file"
            /docker/substitude.py $file $file
        fi
    done
done

# Start Karaf

#echo "-------------------------------------"

echo "-------------------------------------"
echo "Start Karaf ($$) $@"
echo "-------------------------------------"
export KARAF_EXEC=exec
exec ./bin/karaf $@
echo "-------------------------------------"
echo "Finish"
echo "-------------------------------------"
