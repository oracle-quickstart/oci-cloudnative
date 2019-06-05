package api

import (
	"fmt"
	"testing"
)

var (
	TestLogger     bogusLogger = newBogusLogger()
	TestMiddleWare Service     = LoggingMiddleware(TestLogger)(NewFixedService())
)

type bogusLogger struct {
}

func newBogusLogger() bogusLogger {
	return bogusLogger{}
}

func (bl bogusLogger) Log(v ...interface{}) error {
	_, err := fmt.Println(v)
	return err
}

func TestLoginMiddleWare(t *testing.T) {
}
