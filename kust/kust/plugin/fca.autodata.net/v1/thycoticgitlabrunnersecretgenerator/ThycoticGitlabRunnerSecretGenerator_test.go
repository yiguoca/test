package main_test

import (
	"testing"

	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestThycoticGitlabRunnerSecretGenerator(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ThycoticGitlabRunnerSecretGenerator")
	defer th.Reset()

	rm := th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticGitlabRunnerSecretGenerator
metadata:
  name: foo
registration_secret: 1234
runner_secret: 1235
`)
        th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  runner-registration-token: c2VjcmV0Cg==
  runner-token: c2VjcmV0Cg==
kind: Secret
metadata:
  name: foo
`)

	rm = th.LoadAndRunGenerator(`---
apiVersion: fca.autodata.net/v1
kind: ThycoticGitlabRunnerSecretGenerator
metadata:
  name: bar
registration-secret: dummy
`)
        th.AssertActualEqualsExpected(rm, `apiVersion: v1
data:
  runner-registration-token: c2VjcmV0Cg==
  runner-token: ""
kind: Secret
metadata:
  name: bar
`)
}
