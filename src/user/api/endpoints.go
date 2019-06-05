package api

// endpoints.go contains the endpoint definitions, including per-method request
// and response structs. Endpoints are the binding between the service and
// transport.

import (
	"context"

	"github.com/go-kit/kit/endpoint"
	"github.com/go-kit/kit/tracing/opentracing"
	"github.com/junior/mushop/src/user/db"
	"github.com/junior/mushop/src/user/users"
	stdopentracing "github.com/opentracing/opentracing-go"
)

// Endpoints collects the endpoints that comprise the Service.
type Endpoints struct {
	LoginEndpoint       endpoint.Endpoint
	RegisterEndpoint    endpoint.Endpoint
	UserGetEndpoint     endpoint.Endpoint
	UserPostEndpoint    endpoint.Endpoint
	AddressGetEndpoint  endpoint.Endpoint
	AddressPostEndpoint endpoint.Endpoint
	CardGetEndpoint     endpoint.Endpoint
	CardPostEndpoint    endpoint.Endpoint
	DeleteEndpoint      endpoint.Endpoint
	HealthEndpoint      endpoint.Endpoint
}

// MakeEndpoints returns an Endpoints structure, where each endpoint is
// backed by the given service.
func MakeEndpoints(s Service, tracer stdopentracing.Tracer) Endpoints {
	return Endpoints{
		LoginEndpoint:       opentracing.TraceServer(tracer, "GET /login")(MakeLoginEndpoint(s)),
		RegisterEndpoint:    opentracing.TraceServer(tracer, "POST /register")(MakeRegisterEndpoint(s)),
		HealthEndpoint:      opentracing.TraceServer(tracer, "GET /health")(MakeHealthEndpoint(s)),
		UserGetEndpoint:     opentracing.TraceServer(tracer, "GET /customers")(MakeUserGetEndpoint(s)),
		UserPostEndpoint:    opentracing.TraceServer(tracer, "POST /customers")(MakeUserPostEndpoint(s)),
		AddressGetEndpoint:  opentracing.TraceServer(tracer, "GET /addresses")(MakeAddressGetEndpoint(s)),
		AddressPostEndpoint: opentracing.TraceServer(tracer, "POST /addresses")(MakeAddressPostEndpoint(s)),
		CardGetEndpoint:     opentracing.TraceServer(tracer, "GET /cards")(MakeCardGetEndpoint(s)),
		DeleteEndpoint:      opentracing.TraceServer(tracer, "DELETE /")(MakeDeleteEndpoint(s)),
		CardPostEndpoint:    opentracing.TraceServer(tracer, "POST /cards")(MakeCardPostEndpoint(s)),
	}
}

// MakeLoginEndpoint returns an endpoint via the given service.
func MakeLoginEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "login user")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(loginRequest)
		u, err := s.Login(req.Username, req.Password)
		return userResponse{User: u}, err
	}
}

// MakeRegisterEndpoint returns an endpoint via the given service.
func MakeRegisterEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "register user")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(registerRequest)
		id, err := s.Register(req.Username, req.Password, req.Email, req.FirstName, req.LastName)
		return postResponse{ID: id}, err
	}
}

// MakeUserGetEndpoint returns an endpoint via the given service.
func MakeUserGetEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "get users")
		span.SetTag("service", "user")
		defer span.Finish()

		req := request.(GetRequest)

		userspan := stdopentracing.StartSpan("users from db", stdopentracing.ChildOf(span.Context()))
		usrs, err := s.GetUsers(req.ID)
		userspan.Finish()
		if req.ID == "" {
			return EmbedStruct{usersResponse{Users: usrs}}, err
		}
		if len(usrs) == 0 {
			if req.Attr == "addresses" {
				return EmbedStruct{addressesResponse{Addresses: make([]users.Address, 0)}}, err
			}
			if req.Attr == "cards" {
				return EmbedStruct{cardsResponse{Cards: make([]users.Card, 0)}}, err
			}
			return users.User{}, err
		}
		user := usrs[0]
		attrspan := stdopentracing.StartSpan("attributes from db", stdopentracing.ChildOf(span.Context()))
		db.GetUserAttributes(&user)
		attrspan.Finish()
		if req.Attr == "addresses" {
			return EmbedStruct{addressesResponse{Addresses: user.Addresses}}, err
		}
		if req.Attr == "cards" {
			return EmbedStruct{cardsResponse{Cards: user.Cards}}, err
		}
		return user, err
	}
}

// MakeUserPostEndpoint returns an endpoint via the given service.
func MakeUserPostEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "post user")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(users.User)
		id, err := s.PostUser(req)
		return postResponse{ID: id}, err
	}
}

// MakeAddressGetEndpoint returns an endpoint via the given service.
func MakeAddressGetEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "get users")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(GetRequest)
		addrspan := stdopentracing.StartSpan("addresses from db", stdopentracing.ChildOf(span.Context()))
		adds, err := s.GetAddresses(req.ID)
		addrspan.Finish()
		if req.ID == "" {
			return EmbedStruct{addressesResponse{Addresses: adds}}, err
		}
		if len(adds) == 0 {
			return users.Address{}, err
		}
		return adds[0], err
	}
}

// MakeAddressPostEndpoint returns an endpoint via the given service.
func MakeAddressPostEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "post address")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(addressPostRequest)
		id, err := s.PostAddress(req.Address, req.UserID)
		return postResponse{ID: id}, err
	}
}

// MakeUserGetEndpoint returns an endpoint via the given service.
func MakeCardGetEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "get cards")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(GetRequest)
		cardspan := stdopentracing.StartSpan("addresses from db", stdopentracing.ChildOf(span.Context()))
		cards, err := s.GetCards(req.ID)
		cardspan.Finish()
		if req.ID == "" {
			return EmbedStruct{cardsResponse{Cards: cards}}, err
		}
		if len(cards) == 0 {
			return users.Card{}, err
		}
		return cards[0], err
	}
}

// MakeCardPostEndpoint returns an endpoint via the given service.
func MakeCardPostEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "post card")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(cardPostRequest)
		id, err := s.PostCard(req.Card, req.UserID)
		return postResponse{ID: id}, err
	}
}

// MakeLoginEndpoint returns an endpoint via the given service.
func MakeDeleteEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "delete entity")
		span.SetTag("service", "user")
		defer span.Finish()
		req := request.(deleteRequest)
		err = s.Delete(req.Entity, req.ID)
		if err == nil {
			return statusResponse{Status: true}, err
		}
		return statusResponse{Status: false}, err
	}
}

// MakeHealthEndpoint returns current health of the given service.
func MakeHealthEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		var span stdopentracing.Span
		span, ctx = stdopentracing.StartSpanFromContext(ctx, "health check")
		span.SetTag("service", "user")
		defer span.Finish()
		health := s.Health()
		return healthResponse{Health: health}, nil
	}
}

type GetRequest struct {
	ID   string
	Attr string
}

type loginRequest struct {
	Username string
	Password string
}

type userResponse struct {
	User users.User `json:"user"`
}

type usersResponse struct {
	Users []users.User `json:"customer"`
}

type addressPostRequest struct {
	users.Address
	UserID string `json:"userID"`
}

type addressesResponse struct {
	Addresses []users.Address `json:"address"`
}

type cardPostRequest struct {
	users.Card
	UserID string `json:"userID"`
}

type cardsResponse struct {
	Cards []users.Card `json:"card"`
}

type registerRequest struct {
	Username  string `json:"username"`
	Password  string `json:"password"`
	Email     string `json:"email"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
}

type statusResponse struct {
	Status bool `json:"status"`
}

type postResponse struct {
	ID string `json:"id"`
}

type deleteRequest struct {
	Entity string
	ID     string
}

type healthRequest struct {
	//
}

type healthResponse struct {
	Health []Health `json:"health"`
}

type EmbedStruct struct {
	Embed interface{} `json:"_embedded"`
}
