package users

import (
	"crypto/sha1"
	"errors"
	"fmt"
	"io"
	"strconv"
	"time"
)

var (
	ErrNoCustomerInResponse = errors.New("Response has no matching customer")
	ErrMissingField         = "Error missing %v"
)

type User struct {
	FirstName string    `json:"firstName" bson:"firstName"`
	LastName  string    `json:"lastName" bson:"lastName"`
	Email     string    `json:"-" bson:"email"`
	Username  string    `json:"username" bson:"username"`
	Password  string    `json:"-" bson:"password,omitempty"`
	Addresses []Address `json:"-,omitempty" bson:"-"`
	Cards     []Card    `json:"-,omitempty" bson:"-"`
	UserID    string    `json:"id" bson:"-"`
	Links     Links     `json:"_links"`
	Salt      string    `json:"-" bson:"salt"`
}

func New() User {
	u := User{Addresses: make([]Address, 0), Cards: make([]Card, 0)}
	u.NewSalt()
	return u
}

func (u *User) Validate() error {
	if u.FirstName == "" {
		return fmt.Errorf(ErrMissingField, "FirstName")
	}
	if u.LastName == "" {
		return fmt.Errorf(ErrMissingField, "LastName")
	}
	if u.Username == "" {
		return fmt.Errorf(ErrMissingField, "Username")
	}
	if u.Password == "" {
		return fmt.Errorf(ErrMissingField, "Password")
	}
	return nil
}

func (u *User) MaskCCs() {
	for k, c := range u.Cards {
		c.MaskCC()
		u.Cards[k] = c
	}
}

func (u *User) AddLinks() {
	u.Links.AddCustomer(u.UserID)
}

func (u *User) NewSalt() {
	h := sha1.New()
	io.WriteString(h, strconv.Itoa(int(time.Now().UnixNano())))
	u.Salt = fmt.Sprintf("%x", h.Sum(nil))
}
