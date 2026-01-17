ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS
FROM --platform=${BUILDPLATFORM} golang:1.25.5 as builder

COPY . /build/mqtt2prometheus
WORKDIR /build/mqtt2prometheus
RUN make -B build TARGET_FILE=/bin/mqtt2prometheus "GOOS=${TARGETOS}" "GOARCH=${TARGETARCH}"

FROM scratch
COPY --from=builder /bin/mqtt2prometheus /usr/bin/mqtt2prometheus
COPY config.yaml.dist /etc/mqtt2prometheus/config.yaml
ENTRYPOINT ["/usr/bin/mqtt2prometheus"]
