#!/bin/bash
url="$1"
echo ${url}
status_code=0

while [ $status_code -ne 403 ]; do
    status_code=$(curl -o /dev/null -s -w "%{http_code}\n" "$url")
    echo "Waiting for server to respond with 403 OK. Current status: $status_code"
    sleep 5 # wait for 5 seconds before trying again
done

echo "Received 403 OK from server."
