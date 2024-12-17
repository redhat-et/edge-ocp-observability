## Kepler from RPM on a host (non-K8s)

Kepler is a research project that that uses eBPF to probe CPU performance counters and Linux kernel tracepoints
to calculate an application's energy consumption. Refer to [Kepler documentation](https://sustainable-computing.io/) for further information.

Kepler can run from an RPM without the need for Kubernetes based system. To install Kepler as an RPM
and manage it as a systemd service, follow [kepler RPM install documentation](https://sustainable-computing.io/installation/kepler-rpm/).

Kepler metrics can be pushed to an OpenShift cluster where it can be visualized centrally with Grafana and a Prometheus Datasource.
(Grafana & Prometheus can also run as pods without K8s but for this example we'll use
[this OpenShift observability setup](../../../observability-hub/README.md).

The rest of this documents assumes:

1. Kepler is running as a systemd service
2. An observability hub is running in OpenShift that the system running Kepler has access to.

### Collect Kepler metrics with OpenTelemetry Collector pod

#### Obtain the OpenShift OpenTelemetry Collector endpoint and update the collector config

```bash
oc -n observability get route otlp-http-otlp-receiver-route  -o jsonpath='{.status.ingress[*].host}'
curl -o otelcol-config.yaml https://raw.githubusercontent.com/redhat-et/edge-ocp-observability/main/edge/sample-app/kepler/non-k8s/otelcol-config.yaml
```

Substitute the otlp-endpoint for `OCP_ROUTE_OTELCOL` in [otelcol-config.yaml](./non-k8s/otelcol-config.yaml).
This file must exist in the directory from where the otel collector pod is launched below.

#### Prepare mTLS certificates and keys in both the edge and OpenShift

To secure traffic from external OpenTelemetry Collector (OTC) to OpenShift OTC,
you can use this [script](./mtls/generate_certs.sh) to create a CA and generate
signed certificates for both the server (OpenShift OTC) and client (edge/external OTC).
This script also creates the configmap, `mtls-certs`, in the observability namespace that
is mounted in OpenShift OTC deployment below.

#### Deploy OpenTelemetry Collector pod

Note that this pod is running with elevated privilege. This is to be expected, since Kepler probes the kernel for data.
In the future, the privilege required to run Kepler can be fine-tuned.

```bash
sudo podman run --rm -d --name otelcol-host \
  --network=host \
  --user=0 \
  --cap-add SYS_ADMIN \
  --tmpfs /tmp --tmpfs /run  \
  -v /var/log/:/var/log  \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v $(pwd)/certs/server.crt:/conf/server.crt.pem:Z \
  -v $(pwd)/certs/server.key:/conf/server.key:Z \
  -v $(pwd)/certs/ca.crt:/conf/ca.crt:Z \
  -v $(pwd)/otelcol-config.yaml:/etc/otelcol-contrib/config.yaml:Z \
  -v $(pwd)/otc:/otc:Z  \
  ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest --config=file:/etc/otelcol-contrib/config.yaml
```

Metrics will be sent from kepler to an OpenTelemetry Collector pod running in OpenShift. From there,
a `prometheusremotewrite` opentelemetry collector exporter will send metrics to a Prometheus pod,
and a Prometheus datasource in Grafana will be used to visualize the data. 

### Deploy Grafana and the Prometheus DataSource with Kepler Dashboard

View the kepler-exporter prometheus metrics in Grafana with the upstream
[kepler exporter dashboard](https://github.com/sustainable-computing-io/kepler/blob/main/grafana-dashboards/Kepler-Exporter.json)

If there is already a Grafana instance with a Prometheus Datasource in OpenShift `-n observability`, run this command to
create the GrafanaDashboard for Kepler:

```bash
oc apply -f edge-ocp-observability/edge/sample-app/kepler/kepler-dashboard.yaml
```

If Grafana is not running in OpenShift,
To deploy Grafana with a Prometheus DataSource in OpenShift, follow [OpenShift observability hub: Grafana](../../../observability-hub/grafana/README.md)
Then, deploy the Kepler dashboard with the above command.

You should now be able to access Grafana with `username: rhel` and `password:rhel` from the grafana route.

You should now be able to access Grafana with `username: rhel` and `password:rhel` from the grafana route.

* Navigate to Dashboards -> to find Kepler Exporter dashboard.
* Navigate to Explore -> to find the Prometheus data source to query metrics from.

Hopefully, you'll see something like this!

![You might see something like this!](../../../images/kepler-microshift.png)
