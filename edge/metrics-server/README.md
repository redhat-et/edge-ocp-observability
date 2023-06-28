### Running kubernetes metrics-server

Add the following labels to `kube-system` namespace

```
      pod-security.kubernetes.io/audit: privileged
      pod-security.kubernetes.io/enforce: privileged
      pod-security.kubernetes.io/warn: privileged
```

Then apply the kube-metrics manifests. It is slighty modified from upstream for MicroShift.
The upstream manifests can be viewed in [kubernetes-sigs/metrics-server repository](https://github.com/kubernetes-sigs/metrics-server)

```bash
oc apply -f manifests/metrics-server/scc.yaml
oc apply -f manifests/metrics-server/metrics-server-components.yaml
```

You should now be able to run `kubectl top` command
to show CPU & memory usage for all pods and node.

```
kubectl top pod -A
kubectl top node
```

### CPU/Memory from kube-metrics-server

`kubectl top pods -A`

![Utilization](../images/top-pods.png)
