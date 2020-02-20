/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
package events

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/go-kit/kit/circuitbreaker"
	"github.com/go-kit/kit/log"
	"github.com/go-kit/kit/tracing/opentracing"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	stdopentracing "github.com/opentracing/opentracing-go"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/streadway/handy/breaker"
	"golang.org/x/net/context"
)

// Mounts the endpoints into a REST HTTP handler.
func MakeHTTPHandler(ctx context.Context, endpoints Endpoints, logger log.Logger, tracer stdopentracing.Tracer) *mux.Router {
	r := mux.NewRouter().StrictSlash(false)
	options := []httptransport.ServerOption{
		httptransport.ServerErrorLogger(logger),
		httptransport.ServerErrorEncoder(encodeError),
	}

	r.Methods("POST").Path("/events").Handler(httptransport.NewServer(
		circuitbreaker.HandyBreaker(breaker.NewBreaker(0.2))(endpoints.Events),
		decodeEventsRequest,
		encodeEventsResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("GET").Path("/health").Handler(httptransport.NewServer(
		circuitbreaker.HandyBreaker(breaker.NewBreaker(0.2))(endpoints.Health),
		decodeHealthRequest,
		encodeHealthResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Handle("/metrics", promhttp.Handler())
	return r
}

func encodeError(_ context.Context, err error, w http.ResponseWriter) {
	code := http.StatusInternalServerError
	w.WriteHeader(code)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"error":       err.Error(),
		"status_code": code,
		"status_text": http.StatusText(code),
	})
}

func decodeEventsRequest(_ context.Context, r *http.Request) (interface{}, error) {
	// Read the content
	var bodyBytes []byte
	if r.Body != nil {
		var err error
		bodyBytes, err = ioutil.ReadAll(r.Body)
		if err != nil {
			return nil, err
		}
	}
	// Save the content
	bodyString := string(bodyBytes)

	// Decode auth request
	var request EventsRequest
	if err := json.Unmarshal(bodyBytes, &request); err != nil {
		return nil, err
	}

	// If source no present, error
	if request.Source == "" {
		return nil, &UnmarshalKeyError{
			Key:  "source",
			JSON: bodyString,
		}
	}
	return request, nil
}

type UnmarshalKeyError struct {
	Key  string
	JSON string
}

func (e *UnmarshalKeyError) Error() string {
	return fmt.Sprintf("Cannot unmarshal object key %q from JSON: %s", e.Key, e.JSON)
}

var ErrInvalidJson = errors.New("Invalid json")

func encodeEventsResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	resp := response.(EventsResponse)
	if resp.Err != nil {
		encodeError(ctx, resp.Err, w)
		return nil
	}
	return encodeResponse(ctx, w, resp.EventsReceived)
}

func decodeHealthRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return struct{}{}, nil
}

func encodeHealthResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	return encodeResponse(ctx, w, response.(healthResponse))
}

func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
	// All of our response objects are JSON serializable, so we just do that.
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	return json.NewEncoder(w).Encode(response)
}
