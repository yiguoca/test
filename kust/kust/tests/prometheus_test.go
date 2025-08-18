package main

import (
	"bufio"
	"os"
	"strings"
	"testing"
)

// Test to Ensure that the KubeControllerManagerDown and KubeSchedulerDown rules are not present in the prometheus manifests
func TestEnsureRulesNotPresent(t *testing.T)  {
	var path = os.Getenv("PROMETHEUS_MANIFEST")
	f, err := os.Open(path)
	if err != nil {
		t.Error(err)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	line := 1
	for scanner.Scan() {
		if strings.Contains(scanner.Text(), "KubeControllerManagerDown") {
			t.Errorf("Unexpected KubeControllerManagerDown found in manifest %s on line: %d, ensure bases/prometheus/kustomization.yaml rule removal patch is updated to match current definition.", path, line )
		}
		if strings.Contains(scanner.Text(), "KubeSchedulerDown") {
			t.Errorf("Unexpected KubeSchedulerDown found in manifest %s on line: %d, ensure bases/prometheus/kustomization.yaml rule removal patch is updated to match current definition.", path, line )
		}
		line++
	}
}

// Test to ensure that the CPUThrottlingHigh PrometheusRule excludes the monitoring namespace from its validation
func TestEnsureCPUThrottlingHighPrometheusRuleExcludesMonitoringNamespace(t *testing.T) {
	var path = os.Getenv("PROMETHEUS_MANIFEST")
	f, err := os.Open(path)
	if err != nil {
		t.Error(err)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	line := 1
	for scanner.Scan() {
		if strings.Contains(scanner.Text(), "CPUThrottlingHigh") {
			// find first instance of container_cpu_cfs_throttled_periods_total and make sure it contains reference to the monitoring namespace
			for scanner.Scan() {
				if strings.Contains(scanner.Text(), "container_cpu_cfs_throttled_periods_total") {
					if strings.Contains(scanner.Text(), "monitoring") {
					} else {
						t.Errorf("CPUThrottlingHigh rule expected to exclude monitoring namespace, but no reference to monitoring detected in manifest %s on line: %d ", path, line)
					}
				}
				line++
			}
		}
		line++
	}

}