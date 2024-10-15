/*
** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/

package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/go-kit/kit/log"
	stdopentracing "github.com/opentracing/opentracing-go"
	zipkin "github.com/openzipkin-contrib/zipkin-go-opentracing"

	"net"
	"net/http"


	"path/filepath"

	"mushop/catalogue"

	"github.com/jmoiron/sqlx"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/weaveworks/common/middleware"
	_ "github.com/godror/godror"
)

const (
	ServiceName = "catalogue"
)

var (
	HTTPLatency = prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "http_request_duration_seconds",
		Help:    "Time (in seconds) spent serving HTTP requests.",
		Buckets: prometheus.DefBuckets,
	}, []string{"method", "path", "status_code", "isWS"})
)

func init() {
	prometheus.MustRegister(HTTPLatency)
}

func main() {
	var (
		// Primary is also the default/main path for DB. For 1 DB use case.
		primary_oadb_user        = strings.TrimSpace(os.Getenv("OADB_USER"))
		primary_oadb_pw          = strings.TrimSpace(os.Getenv("OADB_PW"))
		primary_oadb_service     = strings.TrimSpace(os.Getenv("OADB_SERVICE"))
		primary_oadb_wallet_path = strings.TrimSpace(os.Getenv("PRIMARY_OADB_WALLET_PATH"))
        
		// Config relating to DR use case would have standby DB details as well.
		standby_oadb_user        = strings.TrimSpace(os.Getenv("STANDBY_OADB_USER"))
		standby_oadb_pw          = strings.TrimSpace(os.Getenv("STANDBY_OADB_PW"))
		standby_oadb_service     = strings.TrimSpace(os.Getenv("STANDBY_OADB_SERVICE"))
		standby_oadb_wallet_path = strings.TrimSpace(os.Getenv("STANDBY_OADB_WALLET_PATH"))

		port              = flag.String("port", getEnv("CATALOGUE_PORT", "80"), "Port to bind HTTP listener")
		images            = flag.String("images", "./images/", "Image path")
		connectString     = flag.String("CONNECTSTRING", primary_oadb_user+"/\""+primary_oadb_pw+"\"@"+primary_oadb_service, "Connection String: [username[/password]@][tnsname]]")
		primaryWalletPath = flag.String("PRIMARY_WALLET", primary_oadb_wallet_path, "Primary DB Wallet Path")
		standbyString     = flag.String("STANDBY_CONNECTSTRING", standby_oadb_user+"/\""+standby_oadb_pw+"\"@"+standby_oadb_service, "Standby DB Connection String")
		standbyWalletPath = flag.String("STANDBY_WALLET", standby_oadb_wallet_path, "Standby DB Wallet Path")
		zip               = flag.String("zipkin", os.Getenv("ZIPKIN"), "Zipkin address")
	)

	// Parse the flag values
	flag.Parse()

	// Print some debug information
	fmt.Println("Primary DB Connection String: ", *connectString)
	fmt.Println("Primary Wallet Path: ", *primaryWalletPath)
	fmt.Println("Standby DB Connection String: ", *standbyString)
	fmt.Println("Standby Wallet Path: ", *standbyWalletPath)
	fmt.Println("Zipkin address: ", *zip)

	fmt.Fprintf(os.Stderr, "images: %q\n", *images)
	abs, err := filepath.Abs(*images)
	fmt.Fprintf(os.Stderr, "Abs(images): %q (%v)\n", abs, err)
	pwd, err := os.Getwd()
	fmt.Fprintf(os.Stderr, "Getwd: %q (%v)\n", pwd, err)
	files, _ := filepath.Glob(*images + "/*")
	fmt.Fprintf(os.Stderr, "ls: %q\n", files) // contains a list of all files in the current directory
        fmt.Println("Primary Connection String:", *connectString)
	// Mechanical stuff.
	errc := make(chan error)

	// Log domain.
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.With(logger, "ts", log.DefaultTimestampUTC, "caller", log.DefaultCaller)
	}

	var tracer stdopentracing.Tracer
	{
		if *zip == "" {
			tracer = stdopentracing.NoopTracer{}
		} else {
			// Find service local IP.
			conn, err := net.Dial("udp", "8.8.8.8:80")
			if err != nil {
				logger.Log("err", err)
				os.Exit(1)
			}
			localAddr := conn.LocalAddr().(*net.UDPAddr)
			host := strings.Split(localAddr.String(), ":")[0]
			defer conn.Close()
			logger := log.With(logger, "tracer", "Zipkin")
			logger.Log("addr", zip)
			collector, err := zipkin.NewHTTPCollector(
				*zip,
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

	// Data domain.
    // Try connecting to the primary database
	err = os.Setenv("TNS_ADMIN", *primaryWalletPath)
	fmt.Println("Primary Wallet TNS_ADMIN Env Set: ", os.Getenv("TNS_ADMIN"))
    
	fmt.Println("Giving extra time before connecting to primary DB, Sleeping for 30 seconds...")
    time.Sleep(30 * time.Second) // Sleep for 30 seconds

	db, err := sqlx.Open("godror", *connectString)
	if err != nil {
		logger.Log("Error: Failed to open Primary Database connection. Details: ", err.Error(), *connectString)
	}

	// Test the connection to the primary database
	err = db.Ping()
	if err != nil {
		logger.Log("Error: Unable to connect to Primary Database. Details: ", err.Error(), *connectString)


		err = os.Setenv("TNS_ADMIN", *standbyWalletPath)
		fmt.Println("Standby Wallet Env Set: ", os.Getenv("TNS_ADMIN"))
		logger.Log(err)

		fmt.Println("Giving extra time before connecting to standby DB, Sleeping for 30 seconds...")
    	time.Sleep(30 * time.Second) // Sleep for 30 seconds
		
		db, err = sqlx.Open("godror", *standbyString)
		if err != nil {
			logger.Log("Error: Failed to open standby Database connection. Details: ", err.Error(), *standbyString)
			//os.Exit(1) // Exit if both connections fail
		}

		// Test the connection to the standby database
		err = db.Ping()
		if err != nil {
			logger.Log("Error: Failed to connect standby Database connection. Details: ", err.Error(), *standbyString)
			//os.Exit(1) // Exit if standby connection fails as well
		} else {
		logger.Log("Info", "Connected to Standby Database", "STANDBY_CONNECTSTRING", *standbyString)
		}
	} else {
		logger.Log("Info", "Connected to Primary Database", "CONNECTSTRING", *connectString)
	}

	defer db.Close()



	// Service domain.
	var service catalogue.Service
	{
		service = catalogue.NewCatalogueService(db, logger)
		service = catalogue.LoggingMiddleware(logger)(service)
	}

	// Endpoint domain.
	endpoints := catalogue.MakeEndpoints(service, tracer)

	// HTTP router
	router := catalogue.MakeHTTPHandler(endpoints, *images, logger, tracer)

	httpMiddleware := []middleware.Interface{
		middleware.Instrument{
			Duration:     HTTPLatency,
			RouteMatcher: router,
		},
	}

	// Handler
	handler := middleware.Merge(httpMiddleware...).Wrap(router)

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

// Reads an environment variable value and returns a default value if environment variable does not exist
func getEnv(key string, defaultVal string) string {
    if value, exists := os.LookupEnv(key); exists {
		return value
    }
    return defaultVal
}