This will contain a common set of configurations that are specific to the type of storage (prod/non-prod) for each data center(s) if more then one is necessary.

For example we have in the london data center:

- fcaus-ct
- fcaus-ct-storage
- fcaus-te

In our example all 3 need to connect to the non-prod london storage. Instead of copying and pasting much of the configurations we simply just need to supply the groups definition and override what we dont want. This avoids too much repeating.