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
	provider, _ := EnvironmentConfigurationProvider()

	handler, logger := WireUp(ctx, opentracing.GlobalTracer(), provider, "test")

	ts := httptest.NewServer(handler)
	defer ts.Close()

	request := EventsRequest{
		Source: "test",
		Track:  "xyx",
	}
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

	logger.Log("Success", response.Success)

	expected := true
	if response.Success != expected {
		t.Errorf("Events returned unexpected result: got %v expected %v",
			response.Success, expected)
	}

}
