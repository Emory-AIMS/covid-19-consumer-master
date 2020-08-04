#!/usr/bin/env bash

# shellcheck disable=SC2046
docker stop $( docker ps -q )
docker rm covid-19-web1
docker rmi registry.gitlab.com/coronavirus-outbreak-control/covid-19-consumer-server
docker-compose up
