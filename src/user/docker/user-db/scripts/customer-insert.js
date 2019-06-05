function get_results(result) {
    print(tojson(result));
}

function insert_customer(object) {
    print(db.customers.insert(object));
}

insert_customer({
    "_id": ObjectId("57a98d98e4b00679b4a830af"),
    "firstName": "Eve",
    "lastName": "Berger",
    "username": "Eve_Berger",
    "password": "fec51acb3365747fc61247da5e249674cf8463c2",
    "salt": "c748112bc027878aa62812ba1ae00e40ad46d497",
    "addresses": [ObjectId("57a98d98e4b00679b4a830ad")],
    "cards": [ObjectId("57a98d98e4b00679b4a830ae")]
});
//pass eve
insert_customer({
    "_id": ObjectId("57a98d98e4b00679b4a830b2"),
    "firstName": "User",
    "lastName": "Name",
    "username": "user",
    "password": "e2de7202bb2201842d041f6de201b10438369fb8",
    "salt": "6c1c6176e8b455ef37da13d953df971c249d0d8e",
    "addresses": [ObjectId("57a98d98e4b00679b4a830b0")],
    "cards": [ObjectId("57a98d98e4b00679b4a830b1")]
});
//pass password
insert_customer({
    "_id": ObjectId("57a98d98e4b00679b4a830b5"),
    "firstName": "User1",
    "lastName": "Name1",
    "username": "user1",
    "password": "8f31df4dcc25694aeb0c212118ae37bbd6e47bcd",
    "salt": "bd832b0e10c6882deabc5e8e60a37689e2b708c2",
    "addresses": [ObjectId("57a98d98e4b00679b4a830b3")],
    "cards": [ObjectId("57a98d98e4b00679b4a830b4")]
});
//pass passsord
print("_______CUSTOMER DATA_______");
db.customers.find().forEach(get_results);
print("______END CUSTOMER DATA_____");
