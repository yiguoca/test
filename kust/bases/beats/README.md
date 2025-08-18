# beats

Base supporting logging clusters beats shipping to [Elastic Cloud on Kubernetes (ECK)](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html) operated elastic stack instance.  
_Note:_ The beats base relies on stage1 of the elastic-system base being installed in the cluster. CRD from ECK are used to configure the beats daemonsets. 
_Note:_ Setup base is run, typically as a job, on the kuberentes cluster initializing ECK. Setup does not need to be rerun for any other cluster we plan to ship data from. 

Beats base currently provides installation of `filebeats` for shipping access and application logs.  
We will likely expand the base to include metricbeats, heatbeat, and potentially other filebeat data shipping.  
Be sure to use delete patch for strategic merge in the overlay to skip installation of any unnecessary deployments.

## Shipping Route

Beats data shippers can be configured to output to different destinations. In our standard configurations we will use Kafka output. To support alternative routes a subfolder within the beats base should be provided.

### Elastic

Shipping route provided as an example alternative base in case a cluster specific use cases does not require the scale and buffering benefits provided by the beats, kafka, logstash, elastic standard route. 

### Kafka

Shipping route defined as the standard configuration of cluster to cluster and in cluster data shipping for logging and monitoring purposes. 

## Overlays 

While the base standardizes the setup for most of the beats configurations we typically use in our clusters, a few cluster specific configurations are expected to be provided when defining an overlay.  

