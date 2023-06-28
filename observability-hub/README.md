## Send Telemetry from edge to OpenShift

**WORK IN PROGRESS**

Telemetry data from the edge (RH Device Edge, MicroShift, Single Node OpenShift) can be directed to OpenShift (OCP)
eliminating the need for an expensive observability stack at the edge.

The OpenTelemetry Collector (OTC) is well-suited for funneling telemetry from the edge to an observability hub.
OTC is also useful to simplify collection at the observability hub by providing a single exposed endpoint to
receive all edge data, while at the edge a single connection can export all data.

### Hub OpenShift cluster

Install `OpenTelemetry Operator`from OperatorHub. Then deploy the stack in `-n observability` as outlined below.


**WORK IN PROGRESS**
