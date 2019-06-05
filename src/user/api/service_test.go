package api

import (
	"testing"

	"github.com/junior/mushop/src/user/users"
)

var (
	TestService  Service
	TestCustomer = users.User{Username: "testuser", Password: ""}
)

func init() {
	TestService = NewFixedService()
}

func TestLogin(t *testing.T) {

}

func TestRegister(t *testing.T) {

}

func TestCalculatePassHash(t *testing.T) {
	hash1 := calculatePassHash("eve", "c748112bc027878aa62812ba1ae00e40ad46d497")
	if hash1 != "fec51acb3365747fc61247da5e249674cf8463c2" {
		t.Error("Eve's password failed hash test")
	}
	hash2 := calculatePassHash("password", "6c1c6176e8b455ef37da13d953df971c249d0d8e")
	if hash2 != "e2de7202bb2201842d041f6de201b10438369fb8" {
		t.Error("user's password failed hash test")
	}
	hash3 := calculatePassHash("password", "bd832b0e10c6882deabc5e8e60a37689e2b708c2")
	if hash3 != "8f31df4dcc25694aeb0c212118ae37bbd6e47bcd" {
		t.Error("user1's password failed hash test")
	}
}
