FROM golang:1.13.6 as build-env

ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0

WORKDIR /go/src/github.com/mattmoor/net-contour

RUN mkdir -p $GOPATH/src/github.com/mattmoor
RUN git clone --depth=1 https://github.com/mattmoor/net-contour $GOPATH/src/github.com/mattmoor/net-contour

RUN go build \
	     -o net-contour \
	     -ldflags '-extldflags "-static"' \
	     -buildmode pie \
	     -tags 'osusergo netgo static_build' \
	     ./cmd/controller

FROM gcr.io/distroless/base
COPY --from=build-env /go/src/github.com/mattmoor/net-contour /net-contour
CMD ["/net-contour"]
