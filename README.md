# docker-mongodb-replicaset

A Docker image to start a dynamic MongoDB 3.2.x ReplicaSet on top of Apache Mesos.

## Introduction

This Docker image was created to be used by the [mesoshq/mongodb-framework](https://github.com/mesoshq/mongodb-framework) project, which is a MongoDB framework running on Mesos. A standalone usage is not recommended, because the ReplicaSet needs to be initialized and configured by the framework scheduler.

The [official MongoDB ReplicaSet tutorial](https://docs.mongodb.org/manual/tutorial/deploy-replica-set/) contains several steps to initialize the ReplicaSet and to add the members. 
It even gets more complicated if you want to add authentication and other things. This image intents to hide this complexity by using a small Node.js application which handles the configuration, together with the usage of Docker environment variables.

### Fault tolerance

The recommended minimal ReplicaSet sizes can be found in the [MongoDB docs](https://docs.mongodb.org/manual/core/replica-set-architectures/#determine-the-number-of-members). It's recommended to run an odd number of nodes, and at least 3 nodes overall. 

### Persistence

By default, the Docker image will only persist its data in the container itself. For production usages, this is probably not the desired behavior. To overcome this, it's recommended to 
[mount a host directory as container volume](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume).

Using plain Docker, this could be done via adding an additional parameter like this: 
  
    -v /host/directory:/container/directory
    
The host directory `/host/directory` will now be available as `/container/directory` in the container. To do this via Marathon, one has to add the `volumes` property to the application JSON as described in the [Marathon docs](https://mesosphere.github.io/marathon/docs/native-docker.html):

The default container paths are the following

* Data directory: `/data/db`
* Logs directory: `/data/logs`

The `run.sh` script will create subfolders for the `MARATHON_APP_ID` set by Marathon during runtime, meaning that each application will have separate data and log folders. This results in the capacity to run multiple MongoDB ReplicaSets on Marathon.

## Overall options

Here's the list of configuration options:

 * `REPLICA_SET`: The name of the ReplicaSet
 * `STORAGE_ENGINE`: Is `wiredTiger` by default, can be `MMAPv1` as well.
 * `JOURNALING`: Is set to `yes` by default. Use `no` to disable.
 * `OPLOG_SIZE`: The size of the OpLog. 

## Service Discovery

Service Discovery is possible via [Mesos DNS](https://github.com/mesosphere/mesos-dns).  
