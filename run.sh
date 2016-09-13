#!/bin/bash
set -m

# Check if we find the HOST ip address from Marathon, otherwise find gateway ip address via route info
if [ "$HOST" != "" ]; then
    ip=$HOST
else
    # Find gateway ip address
    ip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
fi

# Check if we receive a PORT0 from Marathon
if [ "$PORT0" != "" ]; then
    port=$PORT0
else
    # Use standard port
    port="27017"
fi

# Configure storage engine
cmd="mongod --storageEngine $STORAGE_ENGINE"

# Configure bind ip address
cmd="$cmd --bind_ip $ip"

# Configure port
cmd="$cmd --port $port"

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

# Set data directory
export DATA_PATH=/data/db/$REPLICA_SET
mkdir -p $DATA_PATH

cmd="$cmd --dbpath $DATA_PATH"

# Set log directory
export LOG_PATH=/data/logs/$REPLICA_SET
mkdir -p $LOG_PATH

cmd="$cmd --logpath $LOG_PATH/mongodb.log"

# Output the environment for debugging purposes
env

# Output the current configuration
echo $cmd

# Run MongoDB with the above-created parameters
eval $cmd &

# Run in foreground
fg
