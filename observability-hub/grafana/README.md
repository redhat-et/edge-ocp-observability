# Deploy Grafana on OpenShift with Prometheus GrafanaDataSource

The following cmd will:
- Deploy Grafana operator in -n obervability
- Create and configure Grafana instance and route in -n observability
- Define Prometheus datasource in Grafana

```bash
$(pwd)/deploy-grafana.sh
```

## Deploy a GrafanaDashboard to visualize cluster metrics

Check out [github.com/kevchu3/openshift-4-grafana](https://github.com/kevchu3/openshift4-grafana/tree/master/dashboards/crds) for a list of
dashboards to deploy on OpenShift.

Here's an example to download and deploy a GrafanaDashboard for OpenShift 4.16 cluster metrics.
The dashboard is slightly modified from https://github.com/kevchu3/openshift4-grafana/blob/master/dashboards/json_raw/cluster_metrics.ocp416.json

```bash
oc apply -n observability -f cluster-metrics-dashboard/cluster-metrics.yaml 
```
