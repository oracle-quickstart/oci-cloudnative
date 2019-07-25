package api

// transport.go contains the binding from endpoints to a concrete transport.
// In our case we just use a REST-y HTTP transport.

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/go-kit/kit/log"
	"github.com/go-kit/kit/tracing/opentracing"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	"github.com/junior/mushop/src/user/users"
	stdopentracing "github.com/opentracing/opentracing-go"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	ErrInvalidRequest = errors.New("Invalid request")
)

// MakeHTTPHandler mounts the endpoints into a REST-y HTTP handler.
func MakeHTTPHandler(e Endpoints, logger log.Logger, tracer stdopentracing.Tracer) *mux.Router {
	r := mux.NewRouter().StrictSlash(false)
	options := []httptransport.ServerOption{
		httptransport.ServerErrorLogger(logger),
		httptransport.ServerErrorEncoder(encodeError),
	}

	// GET /login       Login
	// GET /register    Register
	// GET /health      Health Check

	r.Methods("GET").Path("/login").Handler(httptransport.NewServer(
		e.LoginEndpoint,
		decodeLoginRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("POST").Path("/register").Handler(httptransport.NewServer(
		e.RegisterEndpoint,
		decodeRegisterRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("GET").PathPrefix("/customers").Handler(httptransport.NewServer(
		e.UserGetEndpoint,
		decodeGetRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("GET").PathPrefix("/cards").Handler(httptransport.NewServer(
		e.CardGetEndpoint,
		decodeGetRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("GET").PathPrefix("/addresses").Handler(httptransport.NewServer(
		e.AddressGetEndpoint,
		decodeGetRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("POST").Path("/customers").Handler(httptransport.NewServer(
		e.UserPostEndpoint,
		decodeUserRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("POST").Path("/addresses").Handler(httptransport.NewServer(
		e.AddressPostEndpoint,
		decodeAddressRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("POST").Path("/cards").Handler(httptransport.NewServer(
		e.CardPostEndpoint,
		decodeCardRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("DELETE").PathPrefix("/").Handler(httptransport.NewServer(
		e.DeleteEndpoint,
		decodeDeleteRequest,
		encodeResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Methods("GET").PathPrefix("/health").Handler(httptransport.NewServer(
		e.HealthEndpoint,
		decodeHealthRequest,
		encodeHealthResponse,
		append(options, httptransport.ServerBefore(opentracing.ContextToHTTP(tracer, logger)))...,
	))
	r.Handle("/metrics", promhttp.Handler())
	return r
}

func encodeError(_ context.Context, err error, w http.ResponseWriter) {
	code := http.StatusInternalServerError
	switch err {
	case ErrUnauthorized:
		code = http.StatusUnauthorized
	}
	w.WriteHeader(code)
	w.Header().Set("Content-Type", "application/hal+json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"error":       err.Error(),
		"status_code": code,
		"status_text": http.StatusText(code),
	})
}

func decodeLoginRequest(_ context.Context, r *http.Request) (interface{}, error) {
	u, p, ok := r.BasicAuth()
	if !ok {
		return loginRequest{}, ErrUnauthorized
	}

	return loginRequest{
		Username: u,
		Password: p,
	}, nil
}

func decodeRegisterRequest(_ context.Context, r *http.Request) (interface{}, error) {
	reg := registerRequest{}
	err := json.NewDecoder(r.Body).Decode(&reg)
	if err != nil {
		return nil, err
	}
	return reg, nil
}

func decodeDeleteRequest(_ context.Context, r *http.Request) (interface{}, error) {
	d := deleteRequest{}
	u := strings.Split(r.URL.Path, "/")
	if len(u) == 3 {
		d.Entity = u[1]
		d.ID = u[2]
		return d, nil
	}
	return d, ErrInvalidRequest
}

func decodeGetRequest(_ context.Context, r *http.Request) (interface{}, error) {
	g := GetRequest{}
	u := strings.Split(r.URL.Path, "/")
	if len(u) > 2 {
		g.ID = u[2]
		if len(u) > 3 {
			g.Attr = u[3]
		}
	}
	return g, nil
}

func decodeUserRequest(_ context.Context, r *http.Request) (interface{}, error) {
	defer r.Body.Close()
	u := users.User{}
	err := json.NewDecoder(r.Body).Decode(&u)
	if err != nil {
		return nil, err
	}
	return u, nil
}

func decodeAddressRequest(_ context.Context, r *http.Request) (interface{}, error) {
	defer r.Body.Close()
	a := addressPostRequest{}
	err := json.NewDecoder(r.Body).Decode(&a)
	if err != nil {
		return nil, err
	}
	return a, nil
}

func decodeCardRequest(_ context.Context, r *http.Request) (interface{}, error) {
	defer r.Body.Close()
	c := cardPostRequest{}
	err := json.NewDecoder(r.Body).Decode(&c)
	if err != nil {
		return nil, err
	}
	return c, nil
}

func decodeHealthRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return struct{}{}, nil
}

func encodeHealthResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	return encodeResponse(ctx, w, response.(healthResponse))
}

func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
	// All of our response objects are JSON serializable, so we just do that.
	w.Header().Set("Content-Type", "application/hal+json")
	return json.NewEncoder(w).Encode(response)
}
