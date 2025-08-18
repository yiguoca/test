# kafka-logging

*_Reminder to install strimzi operator first._*

## Install Strimzi Operator
Before deploying the strimzi resources, the Strimzi operator must be installed.

`kubectl create ns kafka`  
`kubectl create -f strimzi-0.26.1/install/cluster-operator -n kafka`