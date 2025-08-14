# logstash

Install logstash and supporting pipelines to ingest from logging Kafka cluster and index in logging Elasticsearch cluster.  

## Users and access
`piper` user is required for pipeline ingestion with limited permissions. `elastic` user or others with admin privileges could be used but we recommend a limited access profile to reduce risk of accidental incidents. See `elastic/stage1` for *log_writer* role definition. 
`kafka-logging` cluster is not secured for now so no credentials required.

_Note: `logging` namespace must exist before running the `logstash/stage1` overlay. See the `elastic/stage1` overlay for test cluster where logging namespace is created. Logstash user and role are created during the `elastic/stage1` which logstash relies on. Ideally, `elastic/stage-beats-setup` stage has also already executed considering indexes logstash is configured to use are setup during that kustomization.