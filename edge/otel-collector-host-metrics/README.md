## Collect host metrics using OTC host metrics receiver 

This outlines how to configure the OTC `hostmetrics` receiver for collecting low-level host metrics.
In this example, the OTC is running as a podman container on the host. The metrics are sent to an OTC running
in OpenShift.

Refer to the [opentelemetry-collector-contrib/receiver/hostmetricsreceiver](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/hostmetricsreceiver/README.md) for all available configuration options.

### Prepare mTLS certificates and keys in both the edge and OpenShift

To secure traffic from external OpenTelemetry Collector (OTC) to OpenShift OTC,
follow the [mTLS documentation](../../observability-hub/mtls/mTLS-otel-collectors.md). This will create a CA and
signed certificates for both the server (OpenShift OTC) and client (edge/external OTC).
This document also specifies the configmaps to create in the observability namespace that are 
mounted in OpenShift OTC deployment below. 

### RHEL machine

#### Update OpenTelemetry Collector config file

If you already have an OTC config file on the host, you can modify it to add the hostmetrics receiver and
service. Otherwise, you can download an example config file from this repository.

```bash
curl -o infra-otelconfig.yaml https://raw.githubusercontent.com/redhat-et/edge-ocp-observability/edge/otel-collector-host-metrics/infra-otelconfig.yaml
```

Substitute for `$APPS_DOMAIN` in [infra-otelconfig.yaml](./otelcol-config.yaml) to configure the OpenShift OTC endpoint.

`hostmetrics receiver` additions

```yaml
receivers:
  hostmetrics:
    root_path: /hostfs
    collection_interval: 10s
    scrapers:
      cpu:
      memory:
  hostmetrics/disk:
    root_path: /hostfs
    collection_interval: 30s
    scrapers:
      disk:
      filesystem:
----
service:
---
  pipelines:
    metrics:
      receivers: [hostmetrics,hostmetrics/disk]
---
```

#### Run OpenTelemetry Collector with podman

```bash
mkdir otc # for file-storage extension, if configured

# Note the mtls directory must exist at $(pwd)/.

sudo podman run -d --rm --name otelcol-host \
  --network=host \
  --user=0 \
  --cap-add SYS_ADMIN \
  --tmpfs /tmp --tmpfs /run  \
  -v /var/log/:/var/log  \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v /:/hostfs:ro \
  -v $(pwd)/mtls/certs/server.cert.pem:/conf/server.cert.pem:Z \
  -v $(pwd)/mtls/certs/client.cert.pem:/conf/client.cert.pem:Z \
  -v $(pwd)/mtls/private/client.key.pem:/conf/client.key.pem:Z \
  -v $(pwd)/otelcol-config.yaml:/etc/otelcol-contrib/config.yaml:Z \
  -v $(pwd)/otc:/otc:Z  \
  quay.io/sallyom/otelcolcontrib:ubi9 --config=file:/etc/otelcol-contrib/config.yaml
```

#### Deploy Grafana and the Prometheus DataSource

Metrics should be viewable from prometheus datasource in grafana, or from prometheus UI. 

Run these commands against the **OpenShift hub cluster**

To deploy Grafana with a Prometheus DataSource in OpenShift, follow [OpenShift observability hub: Grafana](../../observability-hub/grafana/README.md)

You should now be able to access Grafana with `username: rhel` and `password:rhel` from the grafana route.

* Navigate to Explore -> to find the Prometheus data source to query metrics from.
