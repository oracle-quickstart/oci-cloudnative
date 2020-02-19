/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
package events

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/go-kit/kit/log"
	"golang.org/x/net/context"

	"github.com/oracle/oci-go-sdk/streaming"
)

// Middleware decorates a service.
type Middleware func(Service) Service

type Service interface {
	PostEvents(source string, track string, events []Event) (EventsReceived, error) // POST /events
	Health() []Health                                                               // GET /health
}

type EventsReceived struct {
	Success bool `json:"success"`
	Length  int  `json:"events"`
}

type Event struct {
	Time   string      `json:"time"`
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
func NewEventsService(
	ctx context.Context,
	client streaming.StreamClient,
	streamID string,
	logger log.Logger) Service {

	return &service{
		ctx:      ctx,
		client:   client,
		streamID: streamID,
		logger:   logger,
	}
}

type service struct {
	ctx      context.Context
	client   streaming.StreamClient
	streamID string
	logger   log.Logger
}

func (s *service) PostEvents(source string, track string, events []Event) (EventsReceived, error) {

	numEvents := len(events)
	s.logger.Log(
		"source", source,
		"track", track,
		"length", numEvents,
	)

	var err error
	success := false

	if numEvents == 0 {
		err = errors.New("no events received")
		return EventsReceived{
			Success: success,
			Length:  numEvents,
		}, err
	}

	// construct messages
	var messages []streaming.PutMessagesDetailsEntry

	for _, evt := range events {
		msg := EventRecord{
			Source: source,
			Track:  track,
		}
		msg.Time = evt.Time
		msg.Type = evt.Type
		msg.Detail = evt.Detail

		data, e := json.Marshal(msg)
		if e == nil {
			// append value
			messages = append(messages, streaming.PutMessagesDetailsEntry{
				Key:   nil,
				Value: data,
			})
		}
	}

	// construct request
	messagesRequest := streaming.PutMessagesRequest{
		StreamId: &s.streamID,
		PutMessagesDetails: streaming.PutMessagesDetails{
			Messages: messages,
		},
	}
	// make request
	_, err = s.client.PutMessages(s.ctx, messagesRequest)
	if err == nil {
		success = true
	}

	return EventsReceived{
		Success: success,
		Length:  numEvents,
	}, err
}

func (s *service) Health() []Health {
	var health []Health
	app := Health{"events", "OK", time.Now().String()}
	health = append(health, app)
	return health
}
