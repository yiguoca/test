package main_test

import (
	"testing"

	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestThycoticSecretGenerator(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ThycoticVSphereCsiSecretGenerator")
	defer th.Reset()

	rm := th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticVSphereCsiSecretGenerator
metadata:
  name: foo-credentials
secret: dummy
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  csi-vsphere.conf: W1ZpcnR1YWxDZW50ZXIgInNlY3JldCJdCmluc2VjdXJlLWZsYWcgPSAiIgp1c2VyID0gInNlY3JldCIKcGFzc3dvcmQgPSAic2VjcmV0IgpkYXRhY2VudGVycyA9ICIi
kind: Secret
metadata:
  name: foo-credentials
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticVSphereCsiSecretGenerator
metadata:
  name: foo-credentials
  namespace: vsphere
secret: dummy
host: "lops-prif-vcsa1.autodatacorp.org"
insecure_flag: "true"
`)
  th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  csi-vsphere.conf: W1ZpcnR1YWxDZW50ZXIgImxvcHMtcHJpZi12Y3NhMS5hdXRvZGF0YWNvcnAub3JnIl0KaW5zZWN1cmUtZmxhZyA9ICJ0cnVlIgp1c2VyID0gInNlY3JldCIKcGFzc3dvcmQgPSAic2VjcmV0IgpkYXRhY2VudGVycyA9ICIi
kind: Secret
metadata:
  name: foo-credentials
  namespace: vsphere
`)

  rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticVSphereCsiSecretGenerator
metadata:
  name: foo-credentials
  namespace: vsphere
secret: dummy
username_key: username
password_key: password
insecure_flag: "true"
`)
  th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  csi-vsphere.conf: W1ZpcnR1YWxDZW50ZXIgInNlY3JldCJdCmluc2VjdXJlLWZsYWcgPSAidHJ1ZSIKdXNlciA9ICJzZWNyZXQiCnBhc3N3b3JkID0gInNlY3JldCIKZGF0YWNlbnRlcnMgPSAiIg==
  secret.password: c2VjcmV0
  secret.username: c2VjcmV0
kind: Secret
metadata:
  name: foo-credentials
  namespace: vsphere
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticVSphereCsiSecretGenerator
metadata:
  name: foo-credentials
  namespace: vsphere
secret: dummy
username_key: username
password_key: password
host: "lops-prif-vcsa1.autodatacorp.org"
insecure_flag: "true"
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  csi-vsphere.conf: W1ZpcnR1YWxDZW50ZXIgImxvcHMtcHJpZi12Y3NhMS5hdXRvZGF0YWNvcnAub3JnIl0KaW5zZWN1cmUtZmxhZyA9ICJ0cnVlIgp1c2VyID0gInNlY3JldCIKcGFzc3dvcmQgPSAic2VjcmV0IgpkYXRhY2VudGVycyA9ICIi
  lops-prif-vcsa1.autodatacorp.org.password: c2VjcmV0
  lops-prif-vcsa1.autodatacorp.org.username: c2VjcmV0
kind: Secret
metadata:
  name: foo-credentials
  namespace: vsphere
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticVSphereCsiSecretGenerator
metadata:
  name: foo-credentials
  namespace: vsphere
secret: dummy
port: 123456
host: 123.123.123.123
datacenters: london
insecure_flag: "true"
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  csi-vsphere.conf: W1ZpcnR1YWxDZW50ZXIgIjEyMy4xMjMuMTIzLjEyMyJdCmluc2VjdXJlLWZsYWcgPSAidHJ1ZSIKdXNlciA9ICJzZWNyZXQiCnBhc3N3b3JkID0gInNlY3JldCIKZGF0YWNlbnRlcnMgPSAibG9uZG9uIgpwb3J0ID0gIjEyMzQ1NiI=
kind: Secret
metadata:
  name: foo-credentials
  namespace: vsphere
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticVSphereCsiSecretGenerator
metadata:
  name: foo-credentials
  namespace: vsphere
secret: dummy
host: "lops-prif-vcsa1.autodatacorp.org"
insecure_flag: "true"
datacenters: "london"

cluster_id: "1234567890"
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  csi-vsphere.conf: W0dsb2JhbF0KY2x1c3Rlci1pZCA9ICIxMjM0NTY3ODkwIgoKW1ZpcnR1YWxDZW50ZXIgImxvcHMtcHJpZi12Y3NhMS5hdXRvZGF0YWNvcnAub3JnIl0KaW5zZWN1cmUtZmxhZyA9ICJ0cnVlIgp1c2VyID0gInNlY3JldCIKcGFzc3dvcmQgPSAic2VjcmV0IgpkYXRhY2VudGVycyA9ICJsb25kb24i
kind: Secret
metadata:
  name: foo-credentials
  namespace: vsphere
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticVSphereCsiSecretGenerator
metadata:
  name: foo-credentials
  namespace: vsphere
secret: dummy
host: "lops-prif-vcsa1.autodatacorp.org"
insecure_flag: "true"
datacenters: "london"

cluster_id: "1234567890"
cluster_distribution: "Openshift"
`)
	th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  csi-vsphere.conf: W0dsb2JhbF0KY2x1c3Rlci1pZCA9ICIxMjM0NTY3ODkwIgpjbHVzdGVyLWRpc3RyaWJ1dGlvbiA9ICJPcGVuc2hpZnQiCgpbVmlydHVhbENlbnRlciAibG9wcy1wcmlmLXZjc2ExLmF1dG9kYXRhY29ycC5vcmciXQppbnNlY3VyZS1mbGFnID0gInRydWUiCnVzZXIgPSAic2VjcmV0IgpwYXNzd29yZCA9ICJzZWNyZXQiCmRhdGFjZW50ZXJzID0gImxvbmRvbiI=
kind: Secret
metadata:
  name: foo-credentials
  namespace: vsphere
`)

}
