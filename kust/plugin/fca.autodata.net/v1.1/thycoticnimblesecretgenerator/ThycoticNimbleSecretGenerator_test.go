package main_test

import (
	"testing"

	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestThycoticSecretGenerator(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1.1", "ThycoticNimbleSecretGenerator")
	defer th.Reset()

	rm := th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1.1
kind: ThycoticNimbleSecretGenerator
metadata:
  name: foo-credentials
secret: dummy
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
kind: Secret
metadata:
  name: foo-credentials
stringData:
  backend: null
  serviceName: null
  servicePort: null
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1.1
kind: ThycoticNimbleSecretGenerator
metadata:
  name: foo-credentials
  namespace: nimble
secret: dummy
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
kind: Secret
metadata:
  name: foo-credentials
  namespace: nimble
stringData:
  backend: null
  serviceName: null
  servicePort: null
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1.1
kind: ThycoticNimbleSecretGenerator
metadata:
  name: foo-credentials
  namespace: nimble
secret: dummy
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
kind: Secret
metadata:
  name: foo-credentials
  namespace: nimble
stringData:
  backend: null
  serviceName: null
  servicePort: null
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1.1
kind: ThycoticNimbleSecretGenerator
metadata:
  name: foo-credentials
  namespace: nimble
secret: dummy
service_name: svc
service_port: 123456
backend: 123.123.123.123
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
kind: Secret
metadata:
  name: foo-credentials
  namespace: nimble
stringData:
  backend: 123.123.123.123
  serviceName: svc
  servicePort: 123456
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1.1
kind: ThycoticNimbleSecretGenerator
metadata:
  name: foo-credentials
  namespace: nimble
secret: dummy
username_key: username
password_key: password
service_name: svc
service_port: 1234567
backend: 123.123.123.123
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  password: c2VjcmV0Cg==
  username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: foo-credentials
  namespace: nimble
stringData:
  backend: 123.123.123.123
  serviceName: svc
  servicePort: 1234567
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1.1
kind: ThycoticNimbleSecretGenerator
metadata:
  name: foo-credentials
  namespace: nimble
secret: dummy
username_key: username
password_key: password
resource_key: backend
service_name: svc
service_port: 12345678
backend: 123.123.123.123 
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  backend: c2VjcmV0Cg==
  password: c2VjcmV0Cg==
  username: c2VjcmV0Cg==
kind: Secret
metadata:
  name: foo-credentials
  namespace: nimble
stringData:
  serviceName: svc
  servicePort: 12345678
`)

}
