package events

import (
	"errors"
	"time"

	"github.com/go-kit/kit/log"
)

// Middleware decorates a service.
type Middleware func(Service) Service

type Service interface {
	EventsReceiver(source string, track string, events []Event) (EventsReceived, error) // POST /events
	Health() []Health                                                                   // GET /health
}

type EventsReceived struct {
	Received bool   `json:"received"`
	Message  string `json:"message"`
}

type Event struct {
	Type   string      `json:"type"`
	Detail interface{} `json:"detail"`
}

type EventRecord struct {
	Event
	Source string `json:"source"`
	Track  string `json:"track"`
}

type Health struct {
	Service string `json:"service"`
	Status  string `json:"status"`
	Time    string `json:"time"`
}

// NewEventsService returns a simple implementation of the Service interface
func NewEventsService(logger log.Logger) Service {
	return &service{}
}

type service struct {
}

func (s *service) EventsReceiver(source string, track string, events []Event) (EventsReceived, error) {
	// if amount == 0 {
	// 	return Authorisation{}, ErrInvalidPaymentAmount
	// }
	// if amount < 0 {
	// 	return Authorisation{}, ErrInvalidPaymentAmount
	// }
	received := false
	message := "Events failed"
	// if amount <= s.declineOverAmount {
	// 	authorised = true
	// 	message = "Events accepted"
	// } else {
	// 	message = fmt.Sprintf("Payment declined: amount exceeds %.2f", s.declineOverAmount)
	// }
	return EventsReceived{
		Received: received,
		Message:  message,
	}, nil
}

func (s *service) Health() []Health {
	var health []Health
	app := Health{"events", "OK", time.Now().String()}
	health = append(health, app)
	return health
}

var ErrInvalidEvent = errors.New("Invalid event")
