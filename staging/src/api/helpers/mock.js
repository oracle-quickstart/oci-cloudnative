/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const Cards = [
  {
    "longNum": "xxxxxxxxxxxx9678",
    "expires": "08/19",
    "ccv": "678",
    "id": "fe95a86e-92b3-4afb-9b82-406860f8e8d8",
    "_links": {
      "card": {
        "href": "http://user/cards/fe95a86e-92b3-4afb-9b82-406860f8e8d8"
      },
      "self": {
        "href": "http://user/cards/fe95a86e-92b3-4afb-9b82-406860f8e8d8"
      }
    }
  },
  {
    "longNum": "xxxxxxxxxxxx5918",
    "expires": "08/19",
    "ccv": "958",
    "id": "423f9ee7-c284-4585-b5f3-b92d406e059d",
    "_links": {
      "card": {
        "href": "http://user/cards/423f9ee7-c284-4585-b5f3-b92d406e059d"
      },
      "self": {
        "href": "http://user/cards/423f9ee7-c284-4585-b5f3-b92d406e059d"
      }
    }
  },
  {
    "longNum": "xxxxxxxxxxxx5205",
    "expires": "08/19",
    "ccv": "280",
    "id": "2861e954-67ee-4b26-ba8b-a349160297b0",
    "_links": {
      "card": {
        "href": "http://user/cards/2861e954-67ee-4b26-ba8b-a349160297b0"
      },
      "self": {
        "href": "http://user/cards/2861e954-67ee-4b26-ba8b-a349160297b0"
      }
    }
  },
  {
    "longNum": "xxxxxxxxxxxx5432",
    "expires": "04/16",
    "ccv": "432",
    "id": "2171513c-28da-40e4-bd18-3bdf42953b28",
    "_links": {
      "card": {
        "href": "http://user/cards/2171513c-28da-40e4-bd18-3bdf42953b28"
      },
      "self": {
        "href": "http://user/cards/2171513c-28da-40e4-bd18-3bdf42953b28"
      }
    }
  }
];

const Addresses = [
  {
    "street": "Whitelees Road",
    "number": "246",
    "country": "United Kingdom",
    "city": "Glasgow",
    "postcode": "G67 3DL",
    "id": "57a98d98e4b00679b4a830ad",
    "_links": {
      "address": {
        "href": "http://user/addresses/57a98d98e4b00679b4a830ad"
      },
      "self": {
        "href": "http://user/addresses/57a98d98e4b00679b4a830ad"
      }
    }
  },
  {
    "street": "Whitelees Road",
    "number": "246",
    "country": "United Kingdom",
    "city": "Glasgow",
    "postcode": "G67 3DL",
    "id": "57a98d98e4b00679b4a830b0",
    "_links": {
      "address": {
        "href": "http://user/addresses/57a98d98e4b00679b4a830b0"
      },
      "self": {
        "href": "http://user/addresses/57a98d98e4b00679b4a830b0"
      }
    }
  },
  {
    "street": "Maes-Y-Deri",
    "number": "4",
    "country": "United Kingdom",
    "city": "Aberdare",
    "postcode": "CF44 6TF",
    "id": "57a98d98e4b00679b4a830b3",
    "_links": {
      "address": {
        "href": "http://user/addresses/57a98d98e4b00679b4a830b3"
      },
      "self": {
        "href": "http://user/addresses/57a98d98e4b00679b4a830b3"
      }
    }
  },
  {
    "street": "my road",
    "number": "3",
    "country": "UK",
    "city": "London",
    "postcode": "",
    "id": "57a98ddce4b00679b4a830d1",
    "_links": {
      "address": {
        "href": "http://user/addresses/57a98ddce4b00679b4a830d1"
      },
      "self": {
        "href": "http://user/addresses/57a98ddce4b00679b4a830d1"
      }
    }
  }
];

const Customers = [
  {
    "firstName": "Fred",
    "lastName": "Berger",
    "username": "fredberger",
    "id": "57a98d98e4b00679b4a830ag",
    "_links": {
      "addresses": {
        "href": "http://user/customers/57a98d98e4b00679b4a830ag/addresses"
      },
      "cards": {
        "href": "http://user/customers/57a98d98e4b00679b4a830ag/cards"
      },
      "customer": {
        "href": "http://user/customers/57a98d98e4b00679b4a830ag"
      },
      "self": {
        "href": "http://user/customers/57a98d98e4b00679b4a830ag"
      }
    }
  },
  {
    "firstName": "User",
    "lastName": "Name",
    "username": "user",
    "id": "57a98d98e4b00679b4a830b1",
    "_links": {
      "addresses": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b1/addresses"
      },
      "cards": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b1/cards"
      },
      "customer": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b1"
      },
      "self": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b1"
      }
    }
  },
  {
    "firstName": "User1",
    "lastName": "Name1",
    "username": "user1",
    "id": "57a98d98e4b00679b4a830b4",
    "_links": {
      "addresses": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b4/addresses"
      },
      "cards": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b4/cards"
      },
      "customer": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b4"
      },
      "self": {
        "href": "http://user/customers/57a98d98e4b00679b4a830b4"
      }
    }
  }
];

module.exports = {
  Addresses,
  Cards,
  Customers,
  response: (prop, data) => ({
    mock: true,
    message: 'NOT REAL DATA - THIS IS FOR DEMONSTRATION ONLY',
    _embedded: {
      [prop]: data
    }
  })
};