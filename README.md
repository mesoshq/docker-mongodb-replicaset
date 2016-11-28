# docker-mongodb-replicaset

A Docker image to start a dynamic MongoDB 3.2.x ReplicaSet on top of Apache Mesos.

## Introduction

This Docker image was created to be used by the [mesoshq/mongodb-framework](https://github.com/mesoshq/mongodb-framework) project, which is a MongoDB framework running on Mesos. A standalone usage is not recommended, because the ReplicaSet needs to be initialized and configured by the framework scheduler.

The [official MongoDB ReplicaSet tutorial](https://docs.mongodb.org/manual/tutorial/deploy-replica-set/) contains several steps to initialize the ReplicaSet and to add the members. 
It even gets more complicated if you want to add authentication and other things. This image intents to hide this complexity by using a small Node.js application which handles the configuration, together with the usage of Docker environment variables.

### Fault tolerance

The recommended minimal ReplicaSet sizes can be found in the [MongoDB docs](https://docs.mongodb.org/manual/core/replica-set-architectures/#determine-the-number-of-members). It's recommended to run an odd number of nodes, and at least 3 nodes overall. 

### Persistence

By default, this image will be configured by the framework scheduler to use [local persistent volumes](http://mesos.apache.org/documentation/latest/persistent-volume/). Therefore, the Mesos agent will create a relative path (defined by `CONTAINER_PATH`) within the Mesos sandbox (`MESOS_SANDBOX`) of the respective task. 

The `run.sh` entrypoint script will then create the following folders:

* Data directory: `$MESOS_SANDBOX/$CONTAINER_PATH/db`
* Logs directory: `$MESOS_SANDBOX/$CONTAINER_PATH/logs`

## Overall options

Here's the list of configuration options:

 * `REPLICA_SET`: The name of the ReplicaSet
 * `STORAGE_ENGINE`: Is `wiredTiger` by default, can be `MMAPv1` as well. Optional.
 * `JOURNALING`: Is set to `yes` by default. Use `no` to disable. Optional.
 * `OPLOG_SIZE`: The size of the OpLog. Optional.
 * `CONTAINER_PATH`: The relative path under the `$MESOS_SANDBOX` where the data should be stored. Optional, default is `data`.

## Service Discovery

Service Discovery is possible via [Mesos DNS](https://github.com/mesosphere/mesos-dns).  
