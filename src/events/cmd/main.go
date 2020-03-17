/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
package main

import (
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"mushop/events"

	"github.com/go-kit/kit/log"
	stdopentracing "github.com/opentracing/opentracing-go"
	zipkin "github.com/openzipkin/zipkin-go-opentracing"
	"golang.org/x/net/context"
)

const (
	ServiceName = "events"
)

func main() {
	var (
		port = flag.String("port", "8080", "Port to bind HTTP listener")
		zipk = flag.String("zipkin", os.Getenv("ZIPKIN"), "Zipkin address")
	)
	flag.Parse()
	var tracer stdopentracing.Tracer
	{
		// Log domain.
		var logger log.Logger
		{
			logger = log.NewLogfmtLogger(os.Stderr)
			logger = log.With(logger, "ts", log.DefaultTimestampUTC)
			logger = log.With(logger, "caller", log.DefaultCaller)
		}
		// Find service local IP.
		conn, err := net.Dial("udp", "8.8.8.8:80")
		if err != nil {
			logger.Log("err", err)
			os.Exit(1)
		}
		localAddr := conn.LocalAddr().(*net.UDPAddr)
		host := strings.Split(localAddr.String(), ":")[0]
		defer conn.Close()
		// zipkin
		if *zipk == "" {
			tracer = stdopentracing.NoopTracer{}
		} else {
			logger := log.With(logger, "tracer", "Zipkin")
			logger.Log("addr", zipk)
			collector, err := zipkin.NewHTTPCollector(
				*zipk,
				zipkin.HTTPLogger(logger),
			)
			if err != nil {
				logger.Log("err", err)
				os.Exit(1)
			}
			tracer, err = zipkin.NewTracer(
				zipkin.NewRecorder(collector, false, fmt.Sprintf("%v:%v", host, port), ServiceName),
			)
			if err != nil {
				logger.Log("err", err)
				os.Exit(1)
			}
		}
		stdopentracing.InitGlobalTracer(tracer)
	}

	// context and error channel
	errc := make(chan error)
	ctx := context.Background()

	// connect oci service
	provider, err := events.EnvironmentConfigurationProvider()
	handler, logger := events.WireUp(ctx, tracer, provider, ServiceName)
	if err != nil {
		logger.Log("error", err)
		logger.Log("warning", "Running without stream configuration")
	}

	// Create and launch the HTTP server.
	go func() {
		logger.Log("transport", "HTTP", "port", *port)
		errc <- http.ListenAndServe(":"+*port, handler)
	}()

	// Capture interrupts.
	go func() {
		c := make(chan os.Signal)
		signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
		errc <- fmt.Errorf("%s", <-c)
	}()

	logger.Log("exit", <-errc)
}
