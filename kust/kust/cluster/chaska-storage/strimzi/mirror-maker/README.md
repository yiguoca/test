# [Strimzi - MirrorMaker2](https://strimzi.io/blog/2020/03/30/introducing-mirrormaker2/)

The Strimzi MirrorMaker2 operator handles running MirrorMaker2 in a kubernetes cluster. It works in conjunction with the Strimzi operator and kafka deployments. 

## Architecture

The Stellantis US production storage clusters use MirrorMaker 2 to replicate data in an Active-Passive setup. There is an active storage cluster where kafka is being used to support production applications. We also have a backup / passive storage cluster where MirrorMaker2 should be deployed to replicate data from the active cluster's Kafka to the passive cluster's Kafka. Note: The events and consumer group offsets from the active Kafka cluster should be replicated to the passive Kafka cluster. 

## Failover Steps

In the event in which the active and passive clusters must be swapped (for example, a hardware failure in the active cluster), the following steps must be completed to switch MirrorMaker 2. For these steps we will refer to the current active cluster as A and the current passive cluster as B. Upon completion of the failover, cluster A will be the passive cluster, and cluster B will be active

1. Ensure the importers in cluster A (ETL namespace) are scaled to 0 so no feeds are being processed while the failover takes place
2. Ensure all active kafka integrating components are deleted or scaled down (to 0) in cluster A
3. Delete the MirrorMaker2 instance in cluster B:
   - `` 
  $kubectl delete KafkaMirrorMaker2 mirror-maker -n kafka 
``
1. To complete the failover, deploy MirrorMaker 2 into cluster A(previously the active cluster). You can use the .gitlab-ci.yml job to deploy (hillsboro-storage-mirror-maker or chaska-storage-mirror-maker).Ensure it starts up and is replicating data into the new passive cluster (cluster B)