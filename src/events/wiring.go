/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
package events

import (
	"net/http"
	"os"

	"github.com/go-kit/kit/log"
	"golang.org/x/net/context"

	stdopentracing "github.com/opentracing/opentracing-go"
	"github.com/prometheus/client_golang/prometheus"

	"github.com/oracle/oci-go-sdk/common"
)

var (
	HTTPLatency = prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "http_request_duration_seconds",
		Help:    "Time (in seconds) spent serving HTTP requests.",
		Buckets: prometheus.DefBuckets,
	}, []string{"method", "path", "status_code", "isWS"})
)

func init() {
	prometheus.MustRegister(HTTPLatency)
}

// WireUp the service to the provided context
func WireUp(
	ctx context.Context,
	tracer stdopentracing.Tracer,
	provider common.ConfigurationProvider,
	serviceName string) (http.Handler, log.Logger) {
	// Logging
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.With(logger, "ts", log.DefaultTimestampUTC)
		logger = log.With(logger, "caller", log.DefaultCaller)
	}

	// Streaming configurations
	client, _ := GetStreamClient(provider)
	streamID := GetStreamID()

	// Service domain
	var service Service
	{
		service = NewEventsService(ctx, client, streamID, logger)
		service = LoggingMiddleware(logger)(service)
	}

	// Endpoint domain
	endpoints := MakeEndpoints(service, tracer)

	router := MakeHTTPHandler(ctx, endpoints, logger, tracer)

	return router, logger
}
