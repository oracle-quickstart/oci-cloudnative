function get_results(result) {
    print(tojson(result));
}

function insert_card(object) {
    print(db.cards.insert(object));
}

insert_card({
    "_id": ObjectId("57a98d98e4b00679b4a830ae"),
    "longNum": "5953580604169678",
    "expires": "08/19",
    "ccv": "678"
});
insert_card({
    "_id": ObjectId("57a98d98e4b00679b4a830b1"),
    "longNum": "5544154011345918",
    "expires": "08/19",
    "ccv": "958"
});
insert_card({
    "_id": ObjectId("57a98d98e4b00679b4a830b4"),
    "longNum": "0908415193175205",
    "expires": "08/19",
    "ccv": "280"
});
insert_card({
    "_id": ObjectId("57a98ddce4b00679b4a830d2"),
    "longNum": "5429804235432",
    "expires": "04/16",
    "ccv": "432"
});

print("________CARD DATA_______");
db.cards.find().forEach(get_results);
print("______END CARD DATA_____");


