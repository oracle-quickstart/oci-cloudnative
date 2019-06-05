package users

import (
	"reflect"
	"testing"
)

func TestAddLinksAdd(t *testing.T) {
	domain = "mydomain"
	a := Address{ID: "test"}
	a.AddLinks()
	h := Href{"http://mydomain/addresses/test"}
	if !reflect.DeepEqual(a.Links["address"], h) {
		t.Error("expected equal address links")
	}

}
