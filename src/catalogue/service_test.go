/*
** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 */
package catalogue

import (
	"os"
	"reflect"
	"strings"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/go-kit/kit/log"
	"github.com/jmoiron/sqlx"
)

var (
	s1 = Product{ID: "1", Brand: "brand1", Title: "title1", Description: "description1", Weight: "1oz", ProductSize: "1x1", Colors: "red", Price: 1.1, Qty: 1, ImageURL: []string{"ImageUrl_11", "ImageUrl_21"}, ImageURL1: "ImageUrl_11", ImageURL2: "ImageUrl_21", Categories: []string{"odd", "prime"}, CategoryString: "odd,prime"}
	s2 = Product{ID: "2", Brand: "brand2", Title: "title2", Description: "description2", Weight: "2oz", ProductSize: "2x2", Colors: "green", Price: 1.2, Qty: 2, ImageURL: []string{"ImageUrl_12", "ImageUrl_22"}, ImageURL1: "ImageUrl_12", ImageURL2: "ImageUrl_22", Categories: []string{"even", "prime"}, CategoryString: "even,prime"}
	s3 = Product{ID: "3", Brand: "brand3", Title: "title3", Description: "description3", Weight: "3oz", ProductSize: "3x3", Colors: "blue", Price: 1.3, Qty: 3, ImageURL: []string{"ImageUrl_13", "ImageUrl_23"}, ImageURL1: "ImageUrl_13", ImageURL2: "ImageUrl_23", Categories: []string{"odd", "prime"}, CategoryString: "odd,prime"}
	s4 = Product{ID: "4", Brand: "brand4", Title: "title4", Description: "description4", Weight: "4oz", ProductSize: "4x4", Colors: "gray", Price: 1.4, Qty: 4, ImageURL: []string{"ImageUrl_14", "ImageUrl_24"}, ImageURL1: "ImageUrl_14", ImageURL2: "ImageUrl_24", Categories: []string{"even"}, CategoryString: "even"}
	s5 = Product{ID: "5", Brand: "brand5", Title: "title5", Description: "description5", Weight: "5oz", ProductSize: "5x5", Colors: "black", Price: 1.5, Qty: 5, ImageURL: []string{"ImageUrl_15", "ImageUrl_25"}, ImageURL1: "ImageUrl_15", ImageURL2: "ImageUrl_25", Categories: []string{"odd", "prime"}, CategoryString: "odd,prime"}

	products   = []Product{s1, s2, s3, s4, s5}
	categories = []string{"odd", "even", "prime"}
)

var logger log.Logger

func TestCatalogueServiceList(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"ID", "BRAND", "TITLE", "DESCRIPTION", "WEIGHT", "PRODUCT_SIZE", "COLORS", "PRICE", "QTY", "IMAGE_URL_1", "IMAGE_URL_2", "CATEGORIES_NAME"}

	// Test Case 1
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s1.ID, s1.Brand, s1.Title, s1.Description, s1.Weight, s1.ProductSize, s1.Colors, s1.Price, s1.Qty, s1.ImageURL[0], s1.ImageURL[1], strings.Join(s1.Categories, ",")).
		AddRow(s2.ID, s2.Brand, s2.Title, s2.Description, s2.Weight, s2.ProductSize, s2.Colors, s2.Price, s2.Qty, s2.ImageURL[0], s2.ImageURL[1], strings.Join(s2.Categories, ",")).
		AddRow(s3.ID, s3.Brand, s3.Title, s3.Description, s3.Weight, s3.ProductSize, s3.Colors, s3.Price, s3.Qty, s3.ImageURL[0], s3.ImageURL[1], strings.Join(s3.Categories, ",")).
		AddRow(s4.ID, s4.Brand, s4.Title, s4.Description, s4.Weight, s4.ProductSize, s4.Colors, s4.Price, s4.Qty, s4.ImageURL[0], s4.ImageURL[1], strings.Join(s4.Categories, ",")).
		AddRow(s5.ID, s5.Brand, s5.Title, s5.Description, s5.Weight, s5.ProductSize, s5.Colors, s5.Price, s5.Qty, s5.ImageURL[0], s5.ImageURL[1], strings.Join(s5.Categories, ",")))

	// Test Case 2
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s4.ID, s4.Brand, s4.Title, s4.Description, s4.Weight, s4.ProductSize, s4.Colors, s4.Price, s4.Qty, s4.ImageURL[0], s4.ImageURL[1], strings.Join(s4.Categories, ",")).
		AddRow(s1.ID, s1.Brand, s1.Title, s1.Description, s1.Weight, s1.ProductSize, s1.Colors, s1.Price, s1.Qty, s1.ImageURL[0], s1.ImageURL[1], strings.Join(s1.Categories, ",")).
		AddRow(s2.ID, s2.Brand, s2.Title, s2.Description, s2.Weight, s2.ProductSize, s2.Colors, s2.Price, s2.Qty, s2.ImageURL[0], s2.ImageURL[1], strings.Join(s2.Categories, ",")))

	// // Test Case 3
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s1.ID, s1.Brand, s1.Title, s1.Description, s1.Weight, s1.ProductSize, s1.Colors, s1.Price, s1.Qty, s1.ImageURL[0], s1.ImageURL[1], strings.Join(s1.Categories, ",")).
		AddRow(s3.ID, s3.Brand, s3.Title, s3.Description, s3.Weight, s3.ProductSize, s3.Colors, s3.Price, s3.Qty, s3.ImageURL[0], s3.ImageURL[1], strings.Join(s3.Categories, ",")).
		AddRow(s5.ID, s5.Brand, s5.Title, s5.Description, s5.Weight, s5.ProductSize, s5.Colors, s5.Price, s5.Qty, s5.ImageURL[0], s5.ImageURL[1], strings.Join(s5.Categories, ",")))

	s := NewCatalogueService(sqlxDB, logger)
	for _, testcase := range []struct {
		categories []string
		order      string
		pageNum    int
		pageSize   int
		want       []Product
	}{
		{
			categories: []string{},
			order:      "",
			pageNum:    1,
			pageSize:   5,
			want:       []Product{s1, s2, s3, s4, s5},
		},
		{
			categories: []string{},
			order:      "category",
			pageNum:    1,
			pageSize:   3,
			want:       []Product{s4, s1, s2},
		},
		{
			categories: []string{"odd"},
			order:      "id",
			pageNum:    2,
			pageSize:   2,
			want:       []Product{s5},
		},
	} {
		have, err := s.List(testcase.categories, testcase.order, testcase.pageNum, testcase.pageSize)
		if err != nil {
			t.Errorf(
				"List(%v, %s, %d, %d): returned error %s",
				testcase.categories, testcase.order, testcase.pageNum, testcase.pageSize,
				err.Error(),
			)
		}
		if want := testcase.want; !reflect.DeepEqual(want, have) {
			t.Errorf(
				"List(%v, %s, %d, %d): want %v, have %v",
				testcase.categories, testcase.order, testcase.pageNum, testcase.pageSize,
				want, have,
			)
		}
	}
}

func TestCatalogueServiceCount(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"count"}

	mock.ExpectPrepare("SELECT *").ExpectQuery().WillReturnRows(sqlmock.NewRows(cols).AddRow(5))
	mock.ExpectPrepare("SELECT *").ExpectQuery().WillReturnRows(sqlmock.NewRows(cols).AddRow(4))
	mock.ExpectPrepare("SELECT *").ExpectQuery().WillReturnRows(sqlmock.NewRows(cols).AddRow(1))

	s := NewCatalogueService(sqlxDB, logger)
	for _, testcase := range []struct {
		categories []string
		want       int
	}{
		{[]string{}, 5},
		{[]string{"prime"}, 4},
		{[]string{"even", "prime"}, 1},
	} {
		have, err := s.Count(testcase.categories)
		if err != nil {
			t.Errorf(
				"Count(%v): (%s) returned error %s",
				testcase.categories, err.Error(),
				err.Error(),
			)
		}
		if want := testcase.want; want != have {
			t.Errorf("Count(%v): want %d, have %d", testcase.categories, want, have)
		}
	}
}

func TestCatalogueServiceGet(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"ID", "BRAND", "TITLE", "DESCRIPTION", "WEIGHT", "PRODUCT_SIZE", "COLORS", "PRICE", "QTY", "IMAGE_URL_1", "IMAGE_URL_2", "CATEGORIES_NAME"}

	// (Error) Test Cases 1
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols))

	// Test Case 2
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s3.ID, s3.Brand, s3.Title, s3.Description, s3.Weight, s3.ProductSize, s3.Colors, s3.Price, s3.Qty, s3.ImageURL[0], s3.ImageURL[1], strings.Join(s3.Categories, ",")))

	s := NewCatalogueService(sqlxDB, logger)
	{
		// Error case
		for _, id := range []string{
			"0",
		} {
			want := ErrNotFound
			if _, have := s.Get(id); want != have {
				t.Errorf("Get(%s): want %v, have %v", id, want, have)
			}
		}
	}
	{
		// Success case
		for id, want := range map[string]Product{
			"3": s3,
		} {
			have, err := s.Get(id)
			if err != nil {
				t.Errorf("Get(%s): %v", id, err)
				continue
			}
			if !reflect.DeepEqual(want, have) {
				t.Errorf("Get(%s): want %s, have %s", id, want.ID, have.ID)
				continue
			}
		}
	}
}

func TestCatalogueServiceCategories(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"name"}

	mock.ExpectQuery("SELECT name FROM categories").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(categories[0]).
		AddRow(categories[1]).
		AddRow(categories[2]))

	s := NewCatalogueService(sqlxDB, logger)

	have, err := s.Categories()
	if err != nil {
		t.Errorf("Categories(): %v", err)
	}
	if !reflect.DeepEqual(categories, have) {
		t.Errorf("Categories(): want %v, have %v", categories, have)
	}
}

func TestCut(t *testing.T) {
	for _, testcase := range []struct {
		pageNum  int
		pageSize int
		want     []Product
	}{
		{0, 1, []Product{}}, // pageNum 0 is invalid
		{1, 0, []Product{}}, // pageSize 0 is invalid
		{1, 1, []Product{s1}},
		{1, 2, []Product{s1, s2}},
		{1, 5, []Product{s1, s2, s3, s4, s5}},
		{1, 9, []Product{s1, s2, s3, s4, s5}},
		{2, 0, []Product{}},
		{2, 1, []Product{s2}},
		{2, 2, []Product{s3, s4}},
		{2, 3, []Product{s4, s5}},
		{2, 4, []Product{s5}},
		{2, 5, []Product{}},
		{2, 6, []Product{}},
		{3, 0, []Product{}},
		{3, 1, []Product{s3}},
		{3, 2, []Product{s5}},
		{3, 3, []Product{}},
		{4, 1, []Product{s4}},
		{4, 2, []Product{}},
	} {
		have := cut(products, testcase.pageNum, testcase.pageSize)
		if want := testcase.want; !reflect.DeepEqual(want, have) {
			t.Errorf("cut(%d, %d): want %s, have %s", testcase.pageNum, testcase.pageSize, printIDs(want), printIDs(have))
		}
	}
}

// Make test output nicer: just print product IDs.
type printIDs []Product

func (s printIDs) String() string {
	ids := make([]string, len(s))
	for i, ss := range s {
		ids[i] = ss.ID
	}
	return "[" + strings.Join(ids, ", ") + "]"
}
