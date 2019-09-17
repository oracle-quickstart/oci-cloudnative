/*
** Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/

package catalogue

// service.go contains the definition and implementation (business logic) of the
// catalogue service. Everything here is agnostic to the transport (HTTP).

import (
	"errors"
	"strings"
	"time"

	"github.com/go-kit/kit/log"
	"github.com/jmoiron/sqlx"
)

// Service is the catalogue service, providing read operations on a saleable
// catalogue of MuShop products.
type Service interface {
	List(categories []string, order string, pageNum, pageSize int) ([]Product, error) // GET /catalogue
	Count(categories []string) (int, error)                                           // GET /catalogue/size
	Get(id string) (Product, error)                                                   // GET /catalogue/{id}
	Categories() ([]string, error)                                                    // GET /categories
	Health() []Health                                                                 // GET /health
}

// Middleware decorates a Service.
type Middleware func(Service) Service

// Product describes the thing on offer in the catalogue.
type Product struct {
	ID             string   `json:"id" db:"ID"`
	Brand          string   `json:"brand" db:"BRAND"`
	Title          string   `json:"title" db:"TITLE"`
	Description    string   `json:"description" db:"DESCRIPTION"`
	Weight         string   `json:"weight" db:"WEIGHT"`
	ProductSize    string   `json:"product_size" db:"PRODUCT_SIZE"`
	Colors         string   `json:"colors" db:"COLORS"`
	Qty            int      `json:"qty" db:"QTY"`
	Price          float32  `json:"price" db:"PRICE"`
	ImageURL       []string `json:"imageUrl" db:"-"`
	ImageURL1      string   `json:"-" db:"IMAGE_URL_1"`
	ImageURL2      string   `json:"-" db:"IMAGE_URL_2"`
	Categories     []string `json:"category" db:"-"`
	CategoryString string   `json:"-" db:"CATEGORIES_NAME"`
}

// Health describes the health of a service
type Health struct {
	Service string `json:"service"`
	Status  string `json:"status"`
	Time    string `json:"time"`
}

// ErrNotFound is returned when there is no product for a given ID.
var ErrNotFound = errors.New("not found")

// ErrDBConnection is returned when connection with the database fails.
var ErrDBConnection = errors.New("database connection error")

var baseQuery = "SELECT products.sku AS id, products.brand, products.title, products.description, products.weight, products.product_size, products.colors, products.qty, products.price, products.image_url_1, products.image_url_2, categories_name FROM products LEFT JOIN (SELECT product_category.sku , LISTAGG(categories.name, ', ' ON OVERFLOW TRUNCATE '...' WITHOUT COUNT) WITHIN GROUP (ORDER BY sku) AS categories_name FROM product_category LEFT OUTER JOIN categories ON product_category.category_id=categories.category_id GROUP BY product_category.sku) categoriesbundle ON products.sku=categoriesbundle.sku"

// NewCatalogueService returns an implementation of the Service interface,
// with connection to an SQL database.
func NewCatalogueService(db *sqlx.DB, logger log.Logger) Service {
	return &catalogueService{
		db:     db,
		logger: logger,
	}
}

type catalogueService struct {
	db     *sqlx.DB
	logger log.Logger
}

func (s *catalogueService) List(categories []string, order string, pageNum, pageSize int) ([]Product, error) {
	var products []Product
	query := baseQuery

	var args []interface{}

	for i, t := range categories {
		if i == 0 {
			query += " WHERE categories.name=:categoryname"
			args = append(args, t)
		} else {
			query += " OR categories.name=:categoryname"
			args = append(args, t)
		}
	}

	query += " GROUP BY products.sku, products.brand, products.title, products.description, products.weight, products.product_size, products.colors, products.qty, products.price, products.image_url_1, products.image_url_2, categories_name"

	if order != "" {
		query += " ORDER BY :orderby"
		args = append(args, order)
	}

	err := s.db.Select(&products, query, args...)
	if err != nil {
		s.logger.Log("database error", err)
		return []Product{}, ErrDBConnection
	}
	for i, s := range products {
		products[i].ImageURL = []string{s.ImageURL1, s.ImageURL2}
		products[i].Categories = strings.Split(s.CategoryString, ",")
	}

	// DEMO: Change 0 to 850
	time.Sleep(0 * time.Millisecond)

	products = cut(products, pageNum, pageSize)

	return products, nil
}

func (s *catalogueService) Count(categories []string) (int, error) {
	query := "SELECT COUNT(DISTINCT products.sku) FROM products JOIN product_category ON products.sku=product_category.sku JOIN categories ON product_category.category_id=categories.category_id"

	var args []interface{}

	for i, t := range categories {
		if i == 0 {
			query += " WHERE categories.name=:categoryname"
			args = append(args, t)
		} else {
			query += " OR categories.name=:categoryname"
			args = append(args, t)
		}
	}

	sel, err := s.db.Prepare(query)

	if err != nil {
		s.logger.Log("database error", err)
		return 0, ErrDBConnection
	}
	defer sel.Close()

	var count int
	err = sel.QueryRow(args...).Scan(&count)

	if err != nil {
		s.logger.Log("database error", err)
		return 0, ErrDBConnection
	}

	return count, nil
}

func (s *catalogueService) Get(id string) (Product, error) {
	query := baseQuery + " WHERE products.sku =:id GROUP BY products.sku, products.brand, products.title, products.description, products.weight, products.product_size, products.colors, products.qty, products.price, products.image_url_1, products.image_url_2, categories_name"

	var product Product
	err := s.db.Get(&product, query, id)
	if err != nil {
		s.logger.Log("database error", err)
		return Product{}, ErrNotFound
	}

	product.ImageURL = []string{product.ImageURL1, product.ImageURL2}
	product.Categories = strings.Split(product.CategoryString, ",")

	return product, nil
}

func (s *catalogueService) Health() []Health {
	var health []Health
	dbstatus := "OK"

	err := s.db.Ping()
	if err != nil {
		dbstatus = "err"
	}

	app := Health{"catalogue", "OK", time.Now().String()}
	db := Health{"atp:catalogue-data", dbstatus, time.Now().String()}

	health = append(health, app)
	health = append(health, db)

	return health
}

func (s *catalogueService) Categories() ([]string, error) {
	var categories []string
	query := "SELECT name FROM categories"
	rows, err := s.db.Query(query)
	if err != nil {
		s.logger.Log("database error", err)
		return []string{}, ErrDBConnection
	}
	var category string
	for rows.Next() {
		err = rows.Scan(&category)
		if err != nil {
			s.logger.Log("database error", err)
			continue
		}
		categories = append(categories, category)
	}
	return categories, nil
}

func cut(products []Product, pageNum, pageSize int) []Product {
	if pageNum == 0 || pageSize == 0 {
		return []Product{} // pageNum is 1-indexed
	}
	start := (pageNum * pageSize) - pageSize
	if start > len(products) {
		return []Product{}
	}
	end := (pageNum * pageSize)
	if end > len(products) {
		end = len(products)
	}
	return products[start:end]
}
