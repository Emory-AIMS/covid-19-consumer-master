# !/usr/bin/env bash
file="/var/log/nginx/patientstatus.log.tmp"
while IFS= read -r line
do
    if [ "$line" != "" ]; then
        /usr/local/bin/aws sqs send-message --region us-west-1 --queue-url https://sqs.us-west-1.amazonaws.com/018890560418/status-update --message-body "$line" --delay-seconds 5 \
        1>/dev/null
    fi
   
done < $file