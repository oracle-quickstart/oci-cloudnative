/*
** Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/

package catalogue

// transport.go contains the binding from endpoints to a concrete transport.
// In our case we just use a REST-y HTTP transport.

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-kit/kit/circuitbreaker"
	"github.com/go-kit/kit/log"
	"github.com/go-kit/kit/tracing/opentracing"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	stdopentracing "github.com/opentracing/opentracing-go"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/sony/gobreaker"
	"golang.org/x/net/context"
)

// MakeHTTPHandler mounts the endpoints into a REST-y HTTP handler.
func MakeHTTPHandler(e Endpoints, imagePath string, logger log.Logger, tracer stdopentracing.Tracer) *mux.Router {
	r := mux.NewRouter().StrictSlash(false)
	options := []httptransport.ServerOption{
		httptransport.ServerErrorLogger(logger),
		httptransport.ServerErrorEncoder(encodeError),
	}

	// GET /catalogue       List
	// GET /catalogue/size  Count
	// GET /catalogue/{id}  Get
	// GET /categories            Categories
	// GET /health		Health Check

	r.Methods("GET").Path("/catalogue").Handler(httptransport.NewServer(
		circuitbreaker.Gobreaker(gobreaker.NewCircuitBreaker(gobreaker.Settings{
			Name:    "List",
			Timeout: 30 * time.Second,
		}))(e.ListEndpoint),
		decodeListRequest,
		encodeListResponse,
		append(options, httptransport.ServerBefore(opentracing.HTTPToContext(tracer, "GET /catalogue", logger)))...,
	))
	r.Methods("GET").Path("/catalogue/size").Handler(httptransport.NewServer(
		circuitbreaker.Gobreaker(gobreaker.NewCircuitBreaker(gobreaker.Settings{
			Name:    "Count",
			Timeout: 30 * time.Second,
		}))(e.CountEndpoint),
		decodeCountRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.HTTPToContext(tracer, "GET /catalogue/size", logger)))...,
	))
	r.Methods("GET").Path("/catalogue/{id}").Handler(httptransport.NewServer(
		circuitbreaker.Gobreaker(gobreaker.NewCircuitBreaker(gobreaker.Settings{
			Name:    "Get",
			Timeout: 30 * time.Second,
		}))(e.GetEndpoint),
		decodeGetRequest,
		encodeGetResponse, // special case, this one can have an error
		append(options, httptransport.ServerBefore(opentracing.HTTPToContext(tracer, "GET /catalogue/{id}", logger)))...,
	))
	r.Methods("GET").Path("/categories").Handler(httptransport.NewServer(
		circuitbreaker.Gobreaker(gobreaker.NewCircuitBreaker(gobreaker.Settings{
			Name:    "Categories",
			Timeout: 30 * time.Second,
		}))(e.CategoriesEndpoint),
		decodeCategoriesRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.HTTPToContext(tracer, "GET /categories", logger)))...,
	))
	r.Methods("GET").PathPrefix("/catalogue/images/").Handler(http.StripPrefix(
		"/catalogue/images/",
		http.FileServer(http.Dir(imagePath)),
	))
	r.Methods("GET").PathPrefix("/health").Handler(httptransport.NewServer(
		circuitbreaker.Gobreaker(gobreaker.NewCircuitBreaker(gobreaker.Settings{
			Name:    "Health",
			Timeout: 30 * time.Second,
		}))(e.HealthEndpoint),
		decodeHealthRequest,
		encodeHealthResponse,
		append(options, httptransport.ServerBefore(opentracing.HTTPToContext(tracer, "GET /health", logger)))...,
	))
	r.Handle("/metrics", promhttp.Handler())
	return r
}

func encodeError(_ context.Context, err error, w http.ResponseWriter) {
	code := http.StatusInternalServerError
	switch err {
	case ErrNotFound:
		code = http.StatusNotFound
	}
	w.WriteHeader(code)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"error":       err.Error(),
		"status_code": code,
		"status_text": http.StatusText(code),
	})
}

func decodeListRequest(_ context.Context, r *http.Request) (interface{}, error) {
	pageNum := 1
	if page := r.FormValue("page"); page != "" {
		pageNum, _ = strconv.Atoi(page)
	}
	pageSize := 10
	if size := r.FormValue("size"); size != "" {
		pageSize, _ = strconv.Atoi(size)
	}
	order := "id"
	if sort := r.FormValue("sort"); sort != "" {
		order = strings.ToLower(sort)
	}
	categories := []string{}
	if categoriesval := r.FormValue("categories"); categoriesval != "" {
		categories = strings.Split(categoriesval, ",")
	}
	return listRequest{
		Categories: categories,
		Order:      order,
		PageNum:    pageNum,
		PageSize:   pageSize,
	}, nil
}

// encodeListResponse is distinct from the generic encodeResponse because our
// clients expect that we will encode the slice (array) of products directly,
// without the wrapping response object.
func encodeListResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	resp := response.(listResponse)
	return encodeResponse(ctx, w, resp.Products)
}

func decodeCountRequest(_ context.Context, r *http.Request) (interface{}, error) {
	categories := []string{}
	if categoriesval := r.FormValue("categories"); categoriesval != "" {
		categories = strings.Split(categoriesval, ",")
	}
	return countRequest{
		Categories: categories,
	}, nil
}

func decodeGetRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return getRequest{
		ID: mux.Vars(r)["id"],
	}, nil
}

// encodeGetResponse is distinct from the generic encodeResponse because we need
// to special-case when the getResponse object contains a non-nil error.
func encodeGetResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	resp := response.(getResponse)
	if resp.Err != nil {
		encodeError(ctx, resp.Err, w)
		return nil
	}
	return encodeResponse(ctx, w, resp.Product)
}

func decodeCategoriesRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return struct{}{}, nil
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
