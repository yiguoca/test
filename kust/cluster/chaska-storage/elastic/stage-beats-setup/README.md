# stage-beats-setup

We use `stage-beats-setup` overlay for initialization of beats configurations used by the elastic clusters. Initial indexes and index lifecycle management are created in the cluster during this stage.

_Stage is executed after targeted elastic clusters are created._

Following completion of setup, resources created in `stage-beats` should be deleted to limit waste of compute resources.

_logging_ namespace is expected to exist for access and application log setups. This is intended as a safety to avoid logging namespace being deleted when completion cleanup occurs.

## Deleting Indexes

From time to time we may need to delete an index for cleanup or to resolve problematic logging. Our indexes use lifecycle management which rollover at a rate with intent to minimize data loss. Often it will be safe to delete an index but do be careful. After deleting an index it may be required to rerun `stage-beats-setup` to re-create the appropriate indexing.