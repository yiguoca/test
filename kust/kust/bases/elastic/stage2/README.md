After deployment of the elastic logging infrastructure, this stage defines a
 series of dashboards and supporting visualizations to kibana. In order to support
 said visualizations we have defined a new alias called `7days-access`, which
 references the last 7 days access indices in elastic. This is to help limit size of
 the logs to assist in improving query performance.

These are deployed and managed by the following jobs:

### [logging-access-job](./resources/logging-access-job.yaml)

A one time job execution that executes the following in order:

1. create the `7days-access` alias in _elastic_,
2. create the _kibana_ index pattern `7days-access` and have it reference our alias
 from \#1; we also make this the default index index pattern,
3. import to  _kibana_ tags which will be as quick reference aids to our
visualizations and dashboards,
4. import visualizations to  _kibana_,
5. import dashboards to _kibana_.

### [logging-manage-alias-cron](./resources/logging-manage-alias-cron.yaml)

Currently there is an [open issue] surrounding that index templates when defining
 aliases do not utilize the [date math expression]; this means that the templates
 cannot manage when a new index is generated to update the alias based on the
 expression. Further the [ilm] does not update the alias as well. This introduces
 a problem in managing our alias when we expect the to be dynamically generated
 based on the date expressions:

 > Lets assume we have an alias called "today"; and the expression would be
 > "<access-{now/d}-8>".
 >
 > Lets assume today is 8/2/2023, once the alias is created it would map to index
 > "access-2023.08.02-00001",  on the next day the new index is created
 > "access-2023.08.03-00001", you would expect the following:
 >
 > "<access-{now/d}-8>" = "access-2023.08.03"
 >
 > But what you actually get is the following:
 >
 > "<access-{now/d}-8>" = "access-2023.08.02"
 >
 > The next day would be the following:
 >
 > "<access-{now/d}-8>" = "access-2023.08.02"

To help get a round this We utilize simply cron job that performs the following
 operations to assist in managing our alias:

1. Verify that we do we have an index for today
2. If we do have an index for today, check if the index is already part of our alias
3. If its not being managed by our alias, we want to drop our alias and recreate it.

Because the cron is pretty light weight and not load intensive we have scheduled
 the job to execute *every 5 minutes*.

[open issue]: https://github.com/elastic/elasticsearch/issues/7565
[date math expression]: https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-date-math-index-names
[ilm]: https://www.elastic.co/guide/en/elasticsearch/reference/current/index-lifecycle-management.html
