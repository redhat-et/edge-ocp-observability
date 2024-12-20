## Observability at the edge

This repository is a collection of manifests to enable observability in RHEL, RH Device Edge, and OpenShift.

Included are the following observability scenarios:

1. [Observability stack on OpenShift](observability-hub/README.md) <- `updated Dec19,2024`
3. [Kepler RPM (non-K8s) metrics to OpenShift observability stack](edge/sample-app/kepler/README.md) <- `updated Dec19,2024`
3. [Sample Local Application with Traces](edge/sample-app/local-tracegen/README.md) <- `updated Dec19,2024`
3. [MicroShift Kepler deployment to OpenShift observability stack](edge/sample-app/kepler/microshift/README.md)
2. [Performance CoPilot (PCP) in RHEL Device Edge](./edge/edge-pcp-to-ocp/README.md)
2. [OpenTelemetry Collector for Systemd logs, CRIO traces at the edge](edge/otel-collector-infra/README.md)
1. [Kubernetes Metrics Server on MicroShift](edge/metrics-server/README.md)

### Screenshots

Data sent from MicroShift to OpenShift Grafana

![Kepler Dashboard](images/kepler-dashboard-microshift-in-ocp.png)

Prometheus metrics from MicroShift 

![MicroShift metrics](images/microshift-metrics.png)

Jaeger UI from OpenShift showing traces from edge machine

![Jaeger traces exported from virtual machine](images/localjaeger.png)

### Additional Links

[Red Hat Build of OpenTelemetry documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/deploying_rhel_9_on_amazon_web_services/configuring-the-opentelemetry-collector-for-rhel-on-cloud_deploying-a-virtual-machine-on-aws#configuring-the-opentelemetry-collector-for-journald-logging_configuring-the-opentelemetry-collector-for-rhel-on-cloud)

[Deploying Grafana on OpenShift & Integrating with Cluster Metrics](https://cloud.redhat.com/experts/o11y/ocp-grafana/)

