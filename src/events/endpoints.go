/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
package events

import (
	"github.com/go-kit/kit/endpoint"
	"github.com/go-kit/kit/tracing/opentracing"
	stdopentracing "github.com/opentracing/opentracing-go"
	"golang.org/x/net/context"
)

// Endpoints collects the endpoints that comprise the Service.
type Endpoints struct {
	Events endpoint.Endpoint
	Health endpoint.Endpoint
}

// MakeEndpoints returns an Endpoints structure, where each endpoint is
// backed by the given service.
func MakeEndpoints(s Service, tracer stdopentracing.Tracer) Endpoints {
	return Endpoints{
		Events: opentracing.TraceServer(tracer, "POST /events")(MakeEventsEndpoint(s)),
		Health: opentracing.TraceServer(tracer, "GET /health")(MakeHealthEndpoint(s)),
	}
}

// MakeEventsEndpoint returns an endpoint via the given service.
func MakeEventsEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "receive events")
		span.SetTag("service", "events")
		defer span.Finish()
		req := request.(EventsRequest)
		received, err := s.PostEvents(req.Source, req.Track, req.Events)
		return EventsResponse{EventsReceived: received, Err: err}, nil
	}
}

// MakeHealthEndpoint returns current health of the given service.
func MakeHealthEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "health check")
		span.SetTag("service", "events")
		defer span.Finish()
		health := s.Health()
		return healthResponse{Health: health}, nil
	}
}

// EventsRequest represents a request for events tracking
type EventsRequest struct {
	Source string  `json:"source"`
	Track  string  `json:"track"`
	Events []Event `json:"events"`
}

// EventsResponse returns a response of type EventsReceived and an error, Err.
type EventsResponse struct {
	EventsReceived EventsReceived
	Err            error
}

type healthRequest struct {
	//
}

type healthResponse struct {
	Health []Health `json:"health"`
}
