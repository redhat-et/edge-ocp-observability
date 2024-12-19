from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
import time

def setup_tracer(endpoint="http://localhost:4317"):
    provider = TracerProvider()
    exporter = OTLPSpanExporter(endpoint=endpoint, insecure=True)
    span_processor = BatchSpanProcessor(exporter)
    provider.add_span_processor(span_processor)
    trace.set_tracer_provider(provider)
    return trace.get_tracer(__name__)

def generate_trace(tracer):
    with tracer.start_as_current_span("test-span") as span:
        span.set_attribute("test.attribute", "test-value")
        print("Sending trace data to:", endpoint)
        time.sleep(1)  # Simulate some work
        span.add_event("Test event added")

if __name__ == "__main__":
    endpoint = "http://localhost:4317"
    tracer = setup_tracer(endpoint)
    
    for _ in range(5):  # Generate 5 traces
        generate_trace(tracer)
        time.sleep(2)  # Wait between traces
