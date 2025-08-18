# RabbitMQ-System

Deploys the `rabbitmq-system` Namespace including the [rabbitmq/cluster-operator](https://www.rabbitmq.com/kubernetes/operator/quickstart-operator.html) and a basic RabbitmqCluster definition `rabbitmq`.

## Performance Testing
```
kubectl run perf-test --image=pivotalrabbitmq/perf-test -- --uri amqp://$(kubectl -n rabbitmq-system get secret rabbitmq-default-user -o jsonpath='{@.data.username}'|base64 -d):$(kubectl -n rabbitmq-system get secret rabbitmq-default-user -o jsonpath='{@.data.password}'|base64 -d)@$(kubectl -n rabbitmq-system get service rabbitmq -o jsonpath='{.spec.clusterIP}')
```
