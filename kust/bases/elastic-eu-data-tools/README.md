Defines a series of post deployment tasks that can be executed against the elastic
that contains the EU data.

* **[es-data-streams](es-data-streams/)** - configures data streams to elasticsearch
* **[es-redundancy](es-redundancy/)** - configures elasticsearch redundancies
  * azure snapshots repository
  * snapshot life cycle policy - daily backups for indices of `*-data-stream*`
* **[kb-data-views](kb-data-views/)** - configures data views on kibana for visual aid
