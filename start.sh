#!/bin/bash

if [ "x$CONFIG_PROFILE" == "x" ]; then
  CONFIG_PROFILE=default
fi
export CONFIG_PROFILE

cd /opt/karaf

if [ "x$START_REINSTALL" == "x1" ]; then
  rm assembly.mark
  rm installdone.mark
  rm environmentdone.mark
fi

# prepare karaf
cd /opt/karaf
rm instances/instance.properties 

# assembly
cd /opt/karaf
if [ ! "x$PREVENT_ASSEMBLY" == "x1" -a ! -e assemblydone.mark ]; then
    /docker/assembly.sh
    if [  -e /docker/assembly_custom.sh ]; then
      /docker/assembly_custom.sh
    fi
fi
# environment
cd /opt/karaf
if [ ! "x$PREVENT_ENVIRONMENT" == "x1" ]; then
    /docker/environment.sh
    if [  -e /docker/environment_custom.sh ]; then
      /docker/environment_custom.sh
    fi
fi
# install
cd /opt/karaf
if [ ! "x$PREVENT_DEPLOY" == "x1" ]; then
    /docker/deploy.sh
    if [  -e /docker/deploy_custom.sh ]; then
      /docker/deploy_custom.sh
    fi
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
