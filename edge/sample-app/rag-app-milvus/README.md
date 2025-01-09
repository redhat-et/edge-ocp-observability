## Sample Instrumented RAG application

This is a RAG app with a standalone Milvus vector database. The Milvus image is built from [this PR](https://github.com/milvus-io/milvus/pull/38390)
that creates a UBI based Milvus.

The RAG application image is built from this branch of
[ai-lab-recipes simple RAG application](https://github.com/sallyom/locallm/tree/instrument-rag-traces/recipes/natural_language_processing/rag/app)

### Prerequisites

- podman
- model endpoint

#### How to deploy a model server

You can easily spin up a model service using podman desktop's [AI Lab](https://podman-desktop.io/docs/ai-lab).
Or, you can deploy the same model server (llamacpp) from source. The source for a basic llamacpp model-server is in
[ai-lab-recipes/model_servers/llamacpp_python/README.md](https://github.com/sallyom/locallm/tree/instrument-rag-traces/model_servers/llamacpp_python).
Follow either of those to get a `MODEL_ENDPOINT` for the rag application.

### Update the pod definition

Look for the `UPDATE THIS` in [rag-app-milvus.yaml](./rag-app-milvus.yaml)

You'll need to:

- update MODEL_ENDPOINT value (see above)
- create a local directory for milvus data (`mkdir ~/milvus-configs`)
- create a local directory for milvus-configs and add a single file, `embedEtcd.yaml`, (or point to the current directory since the file is
        [here](./embedEtcd.yaml)
- update the rag-app-milvus.yaml volumes section with the local directory absolute paths

```yaml
  volumes:
  - name: milvus-data
    hostPath:
      # UPDATE THIS
      path: /somewhere/volumes/milvus
      type: Directory
  - name: milvus-configs
    hostPath:
      # UPDATE THIS, and populate directory with embedEtcd.yaml
      path: /somewhere/milvus-configs
      type: Directory
```

### Run the pod

```bash
podman kube play rag-app-milvus.yaml
```

### Collect the trace data

You can view the pod with `podman pod list` and containers with `podman ps`
Interact with the pod by visiting your browser at `http://localhost:8501`. When you interact with the application it will generate traces.
View the application pod logs to see the traces.

That's it! Now collect the traces with any OpenTelemetry Collector.

