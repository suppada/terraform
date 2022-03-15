#!/bin/sh -xv

user="welcom18"
passwd="Paparao@1"
tag="v1"
repo_name=welcome

if [ "$#" -eq 0 ]; then
    docker login -u=${user} -p=${passwd}
    docker rmi -f $(docker images -aq)
    docker pull ubuntu
    docker tag ubuntu:latest ${user}/${repo_name}:${tag}
    docker push ${user}/${repo_name}:${tag}
else
    echo "docker already pushed" 
fi