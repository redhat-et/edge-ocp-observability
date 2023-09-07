FROM alpine:latest as prep
RUN apk --update add ca-certificates

FROM otel/opentelemetry-collector-contrib:0.84.0 as builder

FROM ubi9
COPY --from=builder /otelcol-contrib /

ARG USER_UID=10001
USER ${USER_UID}

EXPOSE 4317 55680 55679
ENTRYPOINT ["/otelcol-contrib"]
CMD ["--config", "/etc/otel/config.yaml"]

