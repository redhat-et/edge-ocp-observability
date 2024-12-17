#!/bin/sh

oc apply -f ../operators/base/grafana-operator.yaml
while ! oc get grafana --all-namespaces
do
    echo waiting for grafana custom resource definition to register
    sleep 5
done
oc apply -f $(pwd)/dashboard/02-grafana-serviceaccount.yaml
oc apply -f $(pwd)/dashboard/02-grafana-sa-token-secret.yaml
oc apply -f $(pwd)/dashboard/02-grafana-instance.yaml
oc apply -f $(pwd)/dashboard/03-grafana-route.yaml
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z mygrafana-sa

MONITORING_NS=observability
SECRET=grafana-sa-token

# Define Prometheus datasource
export BEARER_TOKEN=$(echo $(oc get secret $SECRET -n $MONITORING_NS -o json | jq -r '.data.token') | base64 -d)
while [ -z "$BEARER_TOKEN" ]
do
    echo waiting for service account token
    export BEARER_TOKEN=$(oc get secret ${SECRET} -o json -n $MONITORING_NS | jq -Mr '.data.token' | base64 -d) || or true
    sleep 1
done
echo service account token is populated, will now create grafana datasource

while ! oc get grafanadatasource --all-namespaces;
do
    sleep 1
    echo waiting for grafanadatasource custom resource definition to register
done

# Deploy from updated manifest
envsubst < $(pwd)/dashboard/03-grafana-datasource-UPDATETHIS.yaml | oc apply -f -

