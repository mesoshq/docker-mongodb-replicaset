#!/bin/bash
set -m

# Check if we find the HOST ip address from Marathon, otherwise find gateway ip address via route info
if [ "$HOST" != "" ]; then
    ip=$HOST
else
    # Find gateway ip address
    ip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
fi

# Configure storage engine
cmd="mongod --storageEngine $STORAGE_ENGINE"

# Configure bind ip address
cmd="$cmd --bind_ip $ip"

# Configure journaling
if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

# Configure OpLog
if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

# Configure ReplicaSet
if [ "$REPLICA_SET" != "" ]; then
    cmd="$cmd --replSet $REPLICA_SET"
fi

if [ "$MARATHON_APP_ID" != "" ]; then
    app_name=$MARATHON_APP_ID
else
    app_name="/mongodb"
fi

# Set data directory
export DATA_PATH=/data/db$app_name
mkdir -p $DATA_PATH

cmd="$cmd --dbpath $DATA_PATH"

# Set log directory
export LOG_PATH=/data/logs$app_name
mkdir -p $LOG_PATH

cmd="$cmd --logpath $LOG_PATH/mongodb.log"

# Run MongoDB with the above-created parameters
$cmd &

# Run in foreground
fg
