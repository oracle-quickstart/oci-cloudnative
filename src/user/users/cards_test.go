package users

import (
	"reflect"
	"testing"
)

func TestAddLinksCard(t *testing.T) {
	domain = "mydomain"
	c := Card{ID: "test"}
	c.AddLinks()
	h := Href{"http://mydomain/cards/test"}
	if !reflect.DeepEqual(c.Links["card"], h) {
		t.Error("expected equal address links")
	}

}

func TestMaskCC(t *testing.T) {
	test1 := "1234567890"
	c := Card{LongNum: test1}
	c.MaskCC()
	test1comp := "******7890"
	if c.LongNum != test1comp {
		t.Errorf("Expected matching CC number %v received %v", test1comp, test1)
	}
}
