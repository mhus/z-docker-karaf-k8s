#!/bin/bash

VERSION=4.2.6.1

if [  ! -f Dockerfile ]; then
  echo "not a docker configuration"
  return 1
fi

docker stop karaf-k8s-test
docker rm karaf-k8s-test
docker rmi mhus/karaf-k8s-test:$VERSION

if [ "$1" = "clean" ]; then
  docker rmi mhus/karaf-k8s:$VERSION
  docker build --no-cache -t mhus/karaf-k8s:$VERSION .
  shift
else
	docker build -t mhus/karaf-k8s:$VERSION .
fi

if [ "$1" = "test" ]; then
  cd test
  mkdir -p data/karaf
  cp ../../../mhus/mhus-reactive/assembly/reactive-playground-assembly/target/assembly.tar.gz data/local-assembly.tar.gz
  cp -r ../../../mhus/mhus-reactive/assembly/reactive-playground-assembly/src/main/resources/assembly/* data/karaf/
  cp -r ../../../mhus/mhus-reactive/assembly/reactive-playground-docker/profiles/default/* data/karaf/
  cp sample-substitution.txt data/karaf/etc/
  docker build -t mhus/karaf-k8s-test:$VERSION .
  docker run -it --name karaf-k8s-test mhus/karaf-k8s-test:$VERSION
fi

if [ "$1" = "push" ]; then
    docker push "mhus/karaf-k8s:$VERSION"
    docker tag "mhus/karaf-k8s:$VERSION" "mhus/karaf-k8s:last"
    docker push "mhus/karaf-k8s:last"
fi 
