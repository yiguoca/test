package main_test

import (
	"testing"

	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestThycoticSecretGenerator(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ThycoticRabbitMQSecretGenerator")
	defer th.Reset()

	rm := th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticRabbitMQSecretGenerator
metadata:
  name: foo-credentials
secret: dummy
host: foo
`)
        th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  password: c2VjcmV0Cg==
  rabbitmq-host: Zm9v
  rabbitmq-http-port: MTU2NzI=
  rabbitmq-password: c2VjcmV0Cg==
  rabbitmq-port: NTY3Mg==
  rabbitmq-user: c2VjcmV0Cg==
  rabbitmq-vhost: c2VjcmV0
  rabbitmq-vhost-escaped: c2VjcmV0
  username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: foo-credentials
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticRabbitMQSecretGenerator
metadata:
  name: bar-credentials
secret: dummy
host: foo
ports:
  http: 12345
`)
        th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  password: c2VjcmV0Cg==
  rabbitmq-host: Zm9v
  rabbitmq-http-port: MTIzNDU=
  rabbitmq-password: c2VjcmV0Cg==
  rabbitmq-port: NTY3Mg==
  rabbitmq-user: c2VjcmV0Cg==
  rabbitmq-vhost: c2VjcmV0
  rabbitmq-vhost-escaped: c2VjcmV0
  username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: bar-credentials
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticRabbitMQSecretGenerator
metadata:
  name: zoo-credentials
secret: dummy
host: foo
ports:
  http: 12345
  amqp: 54321
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  password: c2VjcmV0Cg==
  rabbitmq-host: Zm9v
  rabbitmq-http-port: MTIzNDU=
  rabbitmq-password: c2VjcmV0Cg==
  rabbitmq-port: NTQzMjE=
  rabbitmq-user: c2VjcmV0Cg==
  rabbitmq-vhost: c2VjcmV0
  rabbitmq-vhost-escaped: c2VjcmV0
  username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: zoo-credentials
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticRabbitMQSecretGenerator
metadata:
  name: crew-credentials
secret: dummy
host: foo
ports:
  amqp: 54321
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  password: c2VjcmV0Cg==
  rabbitmq-host: Zm9v
  rabbitmq-http-port: MTU2NzI=
  rabbitmq-password: c2VjcmV0Cg==
  rabbitmq-port: NTQzMjE=
  rabbitmq-user: c2VjcmV0Cg==
  rabbitmq-vhost: c2VjcmV0
  rabbitmq-vhost-escaped: c2VjcmV0
  username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: crew-credentials
`)

}
