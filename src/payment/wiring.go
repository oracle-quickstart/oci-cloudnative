package payment

import (
	"net/http"
	"os"

	"github.com/go-kit/kit/log"
	"golang.org/x/net/context"

	stdopentracing "github.com/opentracing/opentracing-go"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/weaveworks/common/middleware"
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

func WireUp(ctx context.Context, declineAmount float32, tracer stdopentracing.Tracer, serviceName string) (http.Handler, log.Logger) {
	// Log domain.
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)
		logger = log.NewContext(logger).With("caller", log.DefaultCaller)
	}

	// Service domain.
	var service Service
	{
		service = NewAuthorisationService(declineAmount)
		service = LoggingMiddleware(logger)(service)
	}

	// Endpoint domain.
	endpoints := MakeEndpoints(service, tracer)

	router := MakeHTTPHandler(ctx, endpoints, logger, tracer)

	httpMiddleware := []middleware.Interface{
		middleware.Instrument{
			Duration:     HTTPLatency,
			RouteMatcher: router,
		},
	}

	// Handler
	handler := middleware.Merge(httpMiddleware...).Wrap(router)

	return handler, logger
}
