package main_test

import (
	"testing"

	kusttest_test "sigs.k8s.io/kustomize/api/testutils/kusttest"
)

func TestImageRewriterTransformer(t *testing.T) {
	th := kusttest_test.MakeEnhancedHarness(t).PrepExecPlugin("fca.autodata.net", "v1", "ImageRewriter")
	defer th.Reset()

	rm := th.LoadAndRunTransformer(`---
apiVersion: fca.autodata.net/v1
kind: ImageRewriter
metadata:
  name: fca-hub
placeHolder: fcaus/
registry: fca-hub.autodatacorp.org:5002/fcaus/
#manifestFile: transformers/image-rewriter-list.txt
`, `---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deploy
spec:
  selector:
    matchLabels:
      app: test-deploy
  template:
    spec:
      containers:
        image: fcaus/test:latest
      imagePullPolicy: Always
`)

	th.AssertActualEqualsExpected(rm, `apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deploy
spec:
  selector:
    matchLabels:
      app: test-deploy
  template:
    spec:
      containers:
        image: fca-hub.autodatacorp.org:5002/fcaus/test:latest
      imagePullPolicy: Always
`)

}
