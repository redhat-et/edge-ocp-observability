## Send Telemetry from edge to OpenShift

Telemetry data from the edge (RH Device Edge, MicroShift, Single Node OpenShift) can be directed to OpenShift (OCP)
eliminating the need for an expensive observability stack at the edge.

The OpenTelemetry Collector (OTC) is well-suited for funneling telemetry from the edge to an observability hub.
OTC is also useful to simplify collection at the observability hub by providing a single exposed endpoint to
receive all edge data, while at the edge a single connection can export all data.

Follow this README to configure an observability hub in OpenShift.

### Hub OpenShift cluster

This image shows the list of operators installed. These are available from OperatorHub, or install via kustomize with the command below.

![Installed operators](../images/hub-installed-operators.png)

Install operators with:

```bash
oc apply --kustomize observability-hub/operators/base
```

#### Operator descriptions

1. **Red Hat Build of OpenTelemetry**: The OpenTelemetry Collector (OTC) is provided from this operator. OTC will expose
an OTLP receiver endpoint for edge devices. Metrics, logs and traces will be distributed from the OTC to various backends, all running
within the observability namespace (Loki, Tempo, Grafana, Prometheus).

2. **Observability Operator**: Provides Prometheus APIs and monitoring stack using Prometheus, Alertmanager and Thanos Querier.
Thanos Receive can also be deployed as a sidecar to Prometheus, to enable a remote-write endpoint for the OTC.

3. **Loki Operator**: Provides `LokiStack` API. Loki is the backend for logging.

4. **Tempo Operator**: Provides `TempoStack` API. This is the backend for distributed tracing. An S3-compatible storage (Minio) will be paired with Tempo.

5. **Grafana Operator**: Provides Grafana APIs including `GrafanaDashboard`, `Grafana`, and `GrafanaDataSource` that will be used to visualize telemetry.

### Create custom resources and configurations for observability hub

Create the observablity hub namespace `observability`. If a different namespace is created, be sure to update the resource yamls accordingly.

```bash
oc create ns observability
```

#### Prepare mTLS certificates and keys in both the edge and OpenShift

To secure traffic from external OpenTelemetry Collector (OTC) to OpenShift OTC,
you can use this [script](./mtls/generate_certs.sh) to create a CA and generate
signed certificates for both the server (OpenShift OTC) and client (edge/external OTC).
This script also creates the configmap, `mtls-certs`, in the observability namespace that
is mounted in OpenShift OTC deployment below.

#### OpenTelemetryCollector deployment

Notice the otel-collector manifests assume the `mtls-certs` configmap exists from
the above mTLS section.

```bash
oc apply --kustomize observability-hub/otel-collector
```

#### Tracing Backend (Tempo with Minio for S3 storage)

```bash
# edit storageclassName & secret as necessary
# secret and storage for testing only
oc apply --kustomize observability-hub/tempo
```

#### Metrics Backend (Prometheus)

```bash
oc apply --kustomize observability-hub/prometheus
```

#### Logging Backend (Loki with Minio container for s3 storage)

```bash
# edit storageclassName & secret as necessary
# secret and storage for testing only
oc apply --kustomize observability-hub/loki
```

#### Grafana 

This will deploy a Grafana operator in -n observability, a Grafana instance, and a Prometheus DataSource
The Grafana console is configured with `username: rhel, password: rhel`

```bash
cd observability-hub/grafana
./deploy-grafana.sh
```

### Configure OTC at the edge to send data to observability hub

Now that the observability stack is up and running, edge workloads can now send metrics, logs, and traces to the OTC in OpenShift.

[Configure Performance Co-Pilot at the edge](../edge/edge-pcp-to-ocp/README.md)

[Configure edge OTC to send Systemd logs and CRIO traces](../edge/otel-collector-infra/README.md)

[Push Kepler metrics from host to OpenShift observability stack](../edge/sample-app/kepler/kepler-rpm-host.md)

[Push MicroShift application (Kepler)  metrics to OpenShift observability stack](../edge/sample-app/kepler/README.md)

