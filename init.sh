#!/bin/bash

set -m

if [ "$APP_NAME" == "" ]; then
    echo "No application name (APP_NAME) env var specified. Exiting!"
    exit 1
fi

# Check if there's an env var for the ReplicaSet addition delay
if [ "$ADD_DELAY" != "" ]; then
    add_delay=$ADD_DELAY
else
    add_delay=15
fi

# Gather the MongoDB endpoints from the Marathon API like this: host1:27017,host2:27017 etc.
MONGODB_ENDPOINTS=$(curl -H "Content-Type: application/json" http://master.mesos:8080/v2/apps/$APP_NAME/tasks | jq -r '.tasks | map([.host, (.ports[0]|tostring)] | join(":")) | join(",")')

# Read the MongoDB endpoints as array
IFS=',' read -ra ENDPOINTS <<< "$MONGODB_ENDPOINTS"

echo "Using ${ENDPOINTS[0]} to initialize the ReplicaSet!"

# Connect to the first endpoint and initilize the ReplicaSet
mongo ${ENDPOINTS[0]} --eval "printjson(rs.initiate())"

# Sleep for 5 seconds
sleep 5

# Process the other nodes -> add to ReplicaSet
for endpoint in "${ENDPOINTS[@]:1}"; do
    echo "Adding endpoint $endpoint to the ReplicaSet"
    mongo ${ENDPOINTS[0]} --eval "rs.add('$endpoint')"
    sleep $add_delay
done

# Check the ReplicaSet's status
mongo ${ENDPOINTS[0]} --eval "printjson(rs.status())"