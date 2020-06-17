#!/bin/bash

# prepare karaf
cd /opt/karaf
rm instances/instance.properties 

# environment
cd /opt/karaf
if [ ! "x$PREVENT_ENVIRONMENT" == "x1" ]; then
    /docker/environment.sh
    if [  -e /docker/environment_custom.sh ]; then
      /docker/environment_custom.sh
    fi
fi

# profile

if [ "x$CONFIG_PROFILE" == "x" ]; then
  CONFIG_PROFILE=none
fi
if [ -e /docker/profiles/${CONFIG_PROFILE} ]; then
  echo "- - - - - - - - - - - - - - - - - -"
  echo "Copy profile ${CONFIG_PROFILE} to /opt/karaf"
  cp -rv /docker/profiles/${CONFIG_PROFILE}/* /opt/karaf/
fi

# load environment
if [ "x$SECRETS_DIRECTORY" != "x" ]; then
  for f in $SECRETS_DIRECTORY/* ; do
    if [ -f "$f" ]; then
      n=ENV_$(basename $f|tr . _|tr '[a-z]' '[A-Z]')
      echo Read Secret into $n
      cat $f | read $n
    fi
  done
fi  

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
