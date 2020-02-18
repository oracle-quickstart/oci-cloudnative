package events

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/opentracing/opentracing-go"
	"golang.org/x/net/context"
)

func TestComponent(t *testing.T) {

	ctx := context.Background()

	handler, logger := WireUp(ctx, opentracing.GlobalTracer(), "test")

	ts := httptest.NewServer(handler)
	defer ts.Close()

	var request EventsRequest
	request.Amount = 9.99
	requestBytes, err := json.Marshal(request)
	if err != nil {
		t.Fatal("ERROR", err)
	}

	res, err := http.Post(ts.URL+"/events", "application/json", bytes.NewReader(requestBytes))
	if err != nil {
		t.Fatal("ERROR", err)
	}
	greeting, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		t.Fatal("ERROR", err)
	}
	var response EventsReceived
	json.Unmarshal(greeting, &response)

	logger.Log("Received", response.Received)

	expected := true
	if response.Received != expected {
		t.Errorf("Events returned unexpected result: got %v expected %v",
			response.Received, expected)
	}

}
