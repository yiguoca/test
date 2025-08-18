# [Metacontroller](https://github.com/GoogleCloudPlatform/metacontroller)

Originally written by Google, this controller allows you to take advantage of everything they've learned about running Kubernetes controller/operators.

Typical controller pattern has a Parent resource managing a collection of child resources.  For example, `CronJob` and `Job` form a parent child pairing.

The basic premise is that Metacontroller will call a HTTP "sync" endpoint on your application with the Parent and associated Child objects your app controls every time they change.  You then evaluate the presented state and decide if anything should change and respond back with the desired state.  Metacontroller will handle any work needed to make the desired state a reality.

## No longer maintained
https://github.com/GoogleCloudPlatform/metacontroller/issues/184

There is at least one fork that is being maintained, so we may need to migrate in the future if the Kubernetes API removes something Metacontroller depends on.

## Custom Resources
It's likely your controller is going to manage a Custom Resource.  You must ensure that your Custom Resource Definition has the status "subresource" enabled, or you end up in an endless update loop where every "sync" results in the resource appearing to change, which then triggers another "sync".

```yaml
spec:
  ...
  subresources:
    status: {}
```

## Stages
Stage one installs the CRDs.  
Stage two installs the RBAC and StatefulSet.