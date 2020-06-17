#!/bin/bash

VERSION=4.2.6.0

if [  ! -f Dockerfile ]; then
  echo "not a docker configuration"
  return 1
fi

docker rmi mhus/karaf-k8s:$VERSION

if [ "$1" = "clean" ]; then
	docker build --no-cache -t mhus/karaf-k8s:$VERSION .
else
	docker build -t mhus/karaf-k8s:$VERSION .
fi

if [ "$1" = "test" ]; then
  cd test
  docker rmi mhus/karaf-k8s-test:$VERSION
  docker stop karaf-k8s-test
  docker rm karaf-k8s-test
	docker build -t mhus/karaf-k8s-test:$VERSION .
  docker run -it --name karaf-k8s-test mhus/karaf-k8s-test:$VERSION
fi

if [ "$1" = "push" ]; then
    docker push "mhus/karaf-k8s:$VERSION"
    docker tag "mhus/karaf-k8s:$VERSION" "mhus/karaf-k8s:last"
    docker push "mhus/karaf-k8s:last"
fi 
