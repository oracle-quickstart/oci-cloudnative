/*
** Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/

package catalogue

import (
	"strings"
	"time"

	"github.com/go-kit/kit/log"
)

// LoggingMiddleware logs method calls, parameters, results, and elapsed time.
func LoggingMiddleware(logger log.Logger) Middleware {
	return func(next Service) Service {
		return loggingMiddleware{
			next:   next,
			logger: logger,
		}
	}
}

type loggingMiddleware struct {
	next   Service
	logger log.Logger
}

func (mw loggingMiddleware) List(categories []string, order string, pageNum, pageSize int) (products []Product, err error) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "List",
			"categories", strings.Join(categories, ", "),
			"order", order,
			"pageNum", pageNum,
			"pageSize", pageSize,
			"result", len(products),
			"err", err,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.List(categories, order, pageNum, pageSize)
}

func (mw loggingMiddleware) Count(categories []string) (n int, err error) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Count",
			"categories", strings.Join(categories, ", "),
			"result", n,
			"err", err,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Count(categories)
}

func (mw loggingMiddleware) Get(id string) (s Product, err error) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Get",
			"id", id,
			"product", s.ID,
			"err", err,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Get(id)
}

func (mw loggingMiddleware) Categories() (categories []string, err error) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Categories",
			"result", len(categories),
			"err", err,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Categories()
}

func (mw loggingMiddleware) Health() (health []Health) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Health",
			"result", len(health),
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Health()
}
