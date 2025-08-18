package main_test

import (
	"testing"

	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestThycoticSecretGenerator(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ThycoticSecretGenerator")
	defer th.Reset()

	rm := th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticSecretGenerator
metadata:
  name: foo-credentials
secret: dummy
username_key: username
password_key: password
resource_key: resource
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  password: c2VjcmV0Cg==
  resource: c2VjcmV0Cg==
  username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: foo-credentials
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticSecretGenerator
metadata:
  name: bar-credentials
  namespace: bar
secret: dummy
username_key: new-username
password_key: new-password
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  new-password: c2VjcmV0Cg==
  new-username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: bar-credentials
  namespace: bar
`)

}
