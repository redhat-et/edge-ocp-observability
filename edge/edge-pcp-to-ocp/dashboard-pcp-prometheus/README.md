# Enabling Dashboard for RHEL machine PCP data on OpenShift

The following cmd will:
- Deploy Grafana operator
- Create and configure Grafana instance for PCP metrics
- Define Prometheus datasource
- Define Grafana dashboard

```bash
$(pwd)/deploy-grafana.sh
```

If there is already a Prometheus Datasource in Grafana configured, this is the command
to deploy a GrafanaDashboard for PCP:

```bash
oc apply -f ./dashboard/04-grafana-dashboard.yaml 
```
