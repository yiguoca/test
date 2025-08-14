Defines a series of single execution jobs that can be used to rebuild/copy indices from another elasticsearch to a new host. We use `containers` instead of `initContainers` so that each copy can be run parallel rather than sequential. The job exists in the `logging` namespace because we want to access the `photon-elastic-user` secret and not need to create it. We do recommend that once the job has completed we undeploy it so that its not accidently triggered since it should only be necessary to execute it once.

----

### `logging-backfill-august-job`

This job will copy specific indices from the logging elasticsearch in chaska and dump them into the defined index in the hillsboro elasticsearch. We use [elasticdump] as the tool to copy the indices. The reason for this is because in order to use the built in ES reindex you would need to configure a whitelisting on both ES instances. To get around this we can utilize this [elasticdump] so that a reconfiguration is not necessary.

Due to the size of the indices it may run for multiple days.

[elasticdump]: https://github.com/elasticsearch-dump/elasticsearch-dump

### `config/elasticdump-reindex.sh`

A script that wraps around elasticdump command to import index from one elastic to another. It takes in the following environment variables:

| Variable | Required | Default |  Description |
|:---------|----------|:--------|:-------------|
| `ES_USERNAME` | yes |         | The elastic search username |
| `ES_PASSWORD` | yes |         | The elastic search password |
| `TARGET`      | yes |         | The full path of where the object should be saved to |
| `SOURCE`      | yes |         | The full path as the source object that will be copied over to the target |
| `DATA`        | yes | `data`  | What are we exporting? options = [index, settings, analyzer, data, mapping, policy, alias, template, component_template, index_template]|
| `LIMIT`       | yes | `600`   | How many objects to move in batch per operation limit is approximate for file streams. |
| `SIZE`        | yes | `-1`    | How many objects to retrieve; -1 = no limit |
| `ADDITIONAL_ARGS` | no |      | A simple environment variable that allows you to expand on the options provided to elasticdump command. See [elasticdump / Options] for details. |

[elasticdump / Options]: https://github.com/elasticsearch-dump/elasticsearch-dump#options
