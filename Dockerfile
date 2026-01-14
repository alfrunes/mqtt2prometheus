FROM golang:1.25.5 as builder

COPY . /build/mqtt2prometheus
WORKDIR /build/mqtt2prometheus
RUN make static_build TARGET_FILE=/bin/mqtt2prometheus

FROM scratch
COPY --from=builder /bin/mqtt2prometheus /usr/bin/mqtt2prometheus
COPY config.yaml.dist /etc/mqtt2prometheus/config.yaml
ENTRYPOINT ["/usr/bin/mqtt2prometheus"]
