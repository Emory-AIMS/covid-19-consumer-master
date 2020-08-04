#!/usr/bin/env bash

FILE_NAME=$(dd bs=18 count=1 if=/dev/urandom | base64 | tr +/ =-)-$(hostname)

/usr/local/bin/aws s3 cp --region us-west-1 /var/log/nginx/coronaviruscheck.org/*.tmp s3://s3-temporary-interaction-log-emory/"$FILE_NAME"