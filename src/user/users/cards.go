package users

import (
	"fmt"
	"strings"
)

type Card struct {
	LongNum string `json:"longNum" bson:"longNum"`
	Expires string `json:"expires" bson:"expires"`
	CCV     string `json:"ccv" bson:"ccv"`
	ID      string `json:"id" bson:"-"`
	Links   Links  `json:"_links" bson:"-"`
}

func (c *Card) MaskCC() {
	l := len(c.LongNum) - 4
	c.LongNum = fmt.Sprintf("%v%v", strings.Repeat("*", l), c.LongNum[l:])
}

func (c *Card) AddLinks() {
	c.Links.AddCard(c.ID)
}
