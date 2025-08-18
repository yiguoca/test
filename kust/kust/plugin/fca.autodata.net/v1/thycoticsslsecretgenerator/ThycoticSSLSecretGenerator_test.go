package main_test

import (
	"sigs.k8s.io/kustomize/api/testutils/kusttest"
	"testing"
)

func TestThycoticSSLSecretGenerator(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ThycoticSSLSecretGenerator")
	defer th.Reset()

	rm := th.LoadAndRunGenerator(`
apiVersion: fca.autodata.net/v1
kind: ThycoticSSLSecretGenerator
metadata:
  name: fcaus-wildcard
  namespace: floopy
secret_id: 2591`)

	th.AssertActualEqualsExpected(rm, `
apiVersion: v1
data:
  tls.crt: c2VjcmV0Cg==
  tls.key: c2VjcmV0Cg==
kind: Secret
metadata:
  name: fcaus-wildcard
  namespace: floopy
type: kubernetes.io/tls
`)

}
