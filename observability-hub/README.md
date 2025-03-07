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
within the observability namespace (Vektor, Tempo, Grafana, Prometheus).

3. **Cluster-Logging Operator**: Provides `Vektor` API. Vektor is the backend for logging.

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
This script also creates the secret, `mtls-certs`, in the observability namespace that
is mounted in OpenShift OTC deployment below.

#### Tracing Backend (Tempo with Minio for S3 storage)

```bash
# edit storageclassName & secret as necessary
# secret and storage for testing only
oc apply --kustomize observability-hub/tempo
```

#### OpenTelemetryCollector deployment

Notice the otel-collector manifests assume the `mtls-certs` secret exists from
the above mTLS section.

```bash
oc apply --kustomize observability-hub/otel-collector
```

#### Logging Backend (TBD)

#### Metrics Backend & Grafana 

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

[Push Kepler metrics from host to OpenShift observability stack](../edge/sample-app/kepler/README.md)

[Push MicroShift application (Kepler)  metrics to OpenShift observability stack](../edge/sample-app/kepler/microshift/README.md)

