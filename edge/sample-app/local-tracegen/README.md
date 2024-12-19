## Sample trace generator

To test trace collection with a local opentelemetry-collector, run the following:

```bash
python -m venv venv
source venv/bin/activate
pip install opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation
python local-tracegen/tracegen.py 
deactivate
```

Configure the local opentelemetry-collector with the following minimum to see trace data:

```yaml
receivers:
  otlp:
    protocols:
      http: {}
      grpc: {}

exporters:
  debug:
    verbosity: detailed

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [debug]
```

You should see trace data in the opentelemetry-collector logs.
