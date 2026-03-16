ARG GO_VERSION_SHASUM=sha256:36975a184af9711b31e7e0b39a277c617fd5031650ca7d663fc0e5e5175bcf25
ARG ALPINE_BASE_SHASUM=sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659
FROM golang@${GO_VERSION_SHASUM} AS builder
#checkov:skip=CKV_DOCKER_7 false flag, already set to shasum

ARG ARCH=amd64
ARG CONTAINER_PORT=8080

WORKDIR /app
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=${ARCH} \
    GO111MODULE=on

COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -trimpath -ldflags="-s -w" -o example-blue-green-app


FROM alpine@${ALPINE_BASE_SHASUM} AS final
#checkov:skip=CKV_DOCKER_7 false flag, already set to shasum
WORKDIR /app
RUN adduser --disabled-password nonroot -s /sbin/nologin nonroot
COPY --from=builder --chown=nonroot:nonroot --chmod=755 /app/example-blue-green-app /app/example-blue-green-app
COPY --from=builder --chown=nonroot:nonroot /app/index.html /app/index.html
USER nonroot
EXPOSE ${CONTAINER_PORT}
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD curl -f http://localhost:8080/index.html || exit 1
ENTRYPOINT ["/app/example-blue-green-app"]


