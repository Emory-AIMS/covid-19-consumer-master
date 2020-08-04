#!/bin/bash
cat /dev/null > ./logs/coronaviruscheck.org/postdata.log
cat /dev/null > ./logs/access.log
cat /dev/null > ./logs/error.log
cat /dev/null > ./logs/ping.log

docker stop covid-19-web1
docker rm covid-19-web1
docker rmi docker_covid-19-web1
