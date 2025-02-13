ARG GO_VERSION=1.21.4
ARG TARGET=alpine:3.9

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS builder
ARG TARGETARCH
ARG TARGETOS
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH

RUN apk add --no-cache ca-certificates git

WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download

COPY ./ ./
ARG VERSION
RUN CGO_ENABLED=0 go build -installsuffix 'static' -ldflags "-X main.version=${VERSION}" -o /app .

FROM ${TARGET} AS final

RUN apk update && apk add --no-cache ca-certificates bash && rm -rf /var/cache/apk/*

WORKDIR /bin
COPY --from=builder /app ./htmltest
WORKDIR /test
CMD ["./"]
