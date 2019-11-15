/*
** Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/

package catalogue

// endpoints.go contains the endpoint definitions, including per-method request
// and response structs. Endpoints are the binding between the service and
// transport.

import (
	"github.com/go-kit/kit/endpoint"
	"github.com/go-kit/kit/tracing/opentracing"
	stdopentracing "github.com/opentracing/opentracing-go"
	"golang.org/x/net/context"
)

// Endpoints collects the endpoints that comprise the Service.
type Endpoints struct {
	ListEndpoint       endpoint.Endpoint
	CountEndpoint      endpoint.Endpoint
	GetEndpoint        endpoint.Endpoint
	CategoriesEndpoint endpoint.Endpoint
	HealthEndpoint     endpoint.Endpoint
}

// MakeEndpoints returns an Endpoints structure, where each endpoint is
// backed by the given service.
func MakeEndpoints(s Service, tracer stdopentracing.Tracer) Endpoints {
	return Endpoints{
		ListEndpoint:       opentracing.TraceServer(tracer, "GET /catalogue")(MakeListEndpoint(s)),
		CountEndpoint:      opentracing.TraceServer(tracer, "GET /catalogue/size")(MakeCountEndpoint(s)),
		GetEndpoint:        opentracing.TraceServer(tracer, "GET /catalogue/{id}")(MakeGetEndpoint(s)),
		CategoriesEndpoint: opentracing.TraceServer(tracer, "GET /categories")(MakeCategoriesEndpoint(s)),
		HealthEndpoint:     opentracing.TraceServer(tracer, "GET /health")(MakeHealthEndpoint(s)),
	}
}

// MakeListEndpoint returns an endpoint via the given service.
func MakeListEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(listRequest)
		products, err := s.List(req.Categories, req.Order, req.PageNum, req.PageSize)
		return listResponse{Products: products, Err: err}, err
	}
}

// MakeCountEndpoint returns an endpoint via the given service.
func MakeCountEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(countRequest)
		n, err := s.Count(req.Categories)
		return countResponse{N: n, Err: err}, err
	}
}

// MakeGetEndpoint returns an endpoint via the given service.
func MakeGetEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(getRequest)
		product, err := s.Get(req.ID)
		return getResponse{Product: product, Err: err}, err
	}
}

// MakeCategoriesEndpoint returns an endpoint via the given service.
func MakeCategoriesEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		categories, err := s.Categories()
		return categoriesResponse{Categories: categories, Err: err}, err
	}
}

// MakeHealthEndpoint returns current health of the given service.
func MakeHealthEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		health := s.Health()
		return healthResponse{Health: health}, nil
	}
}

type listRequest struct {
	Categories []string `json:"categories"`
	Order      string   `json:"order"`
	PageNum    int      `json:"pageNum"`
	PageSize   int      `json:"pageSize"`
}

type listResponse struct {
	Products []Product `json:"product"`
	Err      error     `json:"err"`
}

type countRequest struct {
	Categories []string `json:"categories"`
}

type countResponse struct {
	N   int   `json:"size"` // to match original
	Err error `json:"err"`
}

type getRequest struct {
	ID string `json:"id"`
}

type getResponse struct {
	Product Product `json:"product"`
	Err     error   `json:"err"`
}

type categoriesRequest struct {
	//
}

type categoriesResponse struct {
	Categories []string `json:"categories"`
	Err        error    `json:"err"`
}

type healthRequest struct {
	//
}

type healthResponse struct {
	Health []Health `json:"health"`
}
