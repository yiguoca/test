package main_test

import (
	"testing"

	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestThycoticSecretGenerator(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ThycoticRabbitMQFederationUpstreamURIGenerator")
	defer th.Reset()

	rm := th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticRabbitMQFederationUpstreamURIGenerator
metadata:
  name: federation-upstream-foo-uri
secret: dummy
host: foo
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  uri: YW1xcDovL3NlY3JldDpzZWNyZXRAZm9vOjU2NzI=
kind: Secret
metadata:
  name: federation-upstream-foo-uri
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticRabbitMQFederationUpstreamURIGenerator
metadata:
  name: federation-upstream-foo-uri
secret: dummy
host: foo
vhost: /
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  uri: YW1xcDovL3NlY3JldDpzZWNyZXRAZm9vOjU2NzIv
kind: Secret
metadata:
  name: federation-upstream-foo-uri
`)
	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticRabbitMQFederationUpstreamURIGenerator
metadata:
  name: federation-upstream-foo-uri
secret: dummy
host: foo
vhost: my-vhost
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  uri: YW1xcDovL3NlY3JldDpzZWNyZXRAZm9vOjU2NzIvbXktdmhvc3Q=
kind: Secret
metadata:
  name: federation-upstream-foo-uri
`)
}
