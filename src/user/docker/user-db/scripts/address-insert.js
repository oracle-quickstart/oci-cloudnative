function get_results(result) {
    print(tojson(result));
}

function insert_address(object) {
    print(db.addresses.insert(object));
}

insert_address({
    "_id": ObjectId("57a98d98e4b00679b4a830ad"),
    "number": "246",
    "street": "Whitelees Road",
    "city": "Glasgow",
    "postcode": "G67 3DL",
    "country": "United Kingdom"
});
insert_address({
    "_id": ObjectId("57a98d98e4b00679b4a830b0"),
    "number": "246",
    "street": "Whitelees Road",
    "city": "Glasgow",
    "postcode": "G67 3DL",
    "country": "United Kingdom"
});
insert_address({
    "_id": ObjectId("57a98d98e4b00679b4a830b3"),
    "number": "4",
    "street": "Maes-Y-Deri",
    "city": "Aberdare",
    "postcode": "CF44 6TF",
    "country": "United Kingdom"
});
insert_address({
    "_id": ObjectId("57a98ddce4b00679b4a830d1"),
    "number": "3",
    "street": "my road",
    "city": "London",
    "country": "UK"
});

print("________ADDRESS DATA_______");
db.addresses.find().forEach(get_results);
print("______END ADDRESS DATA_____");
