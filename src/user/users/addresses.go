package users

type Address struct {
	Street   string `json:"street" bson:"street,omitempty"`
	Number   string `json:"number" bson:"number,omitempty"`
	Country  string `json:"country" bson:"country,omitempty"`
	City     string `json:"city" bson:"city,omitempty"`
	PostCode string `json:"postcode" bson:"postcode,omitempty"`
	ID       string `json:"id" bson:"-"`
	Links    Links  `json:"_links"`
}

func (a *Address) AddLinks() {
	a.Links.AddAddress(a.ID)
}
