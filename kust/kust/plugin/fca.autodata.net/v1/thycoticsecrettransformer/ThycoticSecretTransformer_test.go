package main_test

import (
  "testing"
  kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestThycoticSecretTransformer(t *testing.T) {
  th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ThycoticSecretTransformer")
  defer th.Reset()

  rm := th.LoadAndRunTransformer(`
apiVersion: fca.autodata.net/v1
kind: ThycoticSecretTransformer
metadata:
  name: foo
`, `apiVersion: v1
kind: ConfigMap
metadata:
  name: foo
data:
  proxysql.cnf: |
    mysql_users =
    (
        {
            username="__SECRET__123:username"
            password="__SECRET__123:password"
            default_hostgroup=11
            max_connections=800
            active=1

        },
        {
            username="__SECRET__124:username"
            password="__SECRET__124:password"
            default_hostgroup=11
            max_connections=200
            active=1
        },
    )
`)
  th.AssertActualEqualsExpected(rm, `
apiVersion: v1
data:
  proxysql.cnf: |
    mysql_users =
    (
        {
            username="secret"
            password="secret"
            default_hostgroup=11
            max_connections=800
            active=1

        },
        {
            username="secret"
            password="secret"
            default_hostgroup=11
            max_connections=200
            active=1
        },
    )
kind: ConfigMap
metadata:
  name: foo
`)
}
