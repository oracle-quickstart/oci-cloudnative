package payment

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/go-kit/kit/log"
	"github.com/go-kit/kit/circuitbreaker"
	"github.com/go-kit/kit/tracing/opentracing"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	stdopentracing "github.com/opentracing/opentracing-go"
	"github.com/prometheus/client_golang/prometheus/promhttp"
        "github.com/streadway/handy/breaker"
	"golang.org/x/net/context"
)

// MakeHTTPHandler mounts the endpoints into a REST-y HTTP handler.
func MakeHTTPHandler(ctx context.Context, e Endpoints, logger log.Logger, tracer stdopentracing.Tracer) *mux.Router {
	r := mux.NewRouter().StrictSlash(false)
	options := []httptransport.ServerOption{
		httptransport.ServerErrorLogger(logger),
		httptransport.ServerErrorEncoder(encodeError),
	}

	r.Methods("POST").Path("/paymentAuth").Handler(httptransport.NewServer(
		ctx,
		circuitbreaker.HandyBreaker(breaker.NewBreaker(0.2))(e.AuthoriseEndpoint),
		decodeAuthoriseRequest,
		encodeAuthoriseResponse,
		append(options, httptransport.ServerBefore(opentracing.FromHTTPRequest(tracer, "POST /paymentAuth", logger)))...,
	))
	r.Methods("GET").Path("/health").Handler(httptransport.NewServer(
		ctx,
		circuitbreaker.HandyBreaker(breaker.NewBreaker(0.2))(e.HealthEndpoint),
		decodeHealthRequest,
		encodeHealthResponse,
		append(options, httptransport.ServerBefore(opentracing.FromHTTPRequest(tracer, "GET /health", logger)))...,
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

func decodeAuthoriseRequest(_ context.Context, r *http.Request) (interface{}, error) {
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
	var request AuthoriseRequest
	if err := json.Unmarshal(bodyBytes, &request); err != nil {
		return nil, err
	}

	// If amount isn't present, error
	if request.Amount == 0.0 {
		return nil, &UnmarshalKeyError{
			Key:  "amount",
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

func encodeAuthoriseResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	resp := response.(AuthoriseResponse)
	if resp.Err != nil {
		encodeError(ctx, resp.Err, w)
		return nil
	}
	return encodeResponse(ctx, w, resp.Authorisation)
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
