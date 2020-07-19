import base64

from locust import HttpUser, task, between
from random import randint, choice


class Web(HttpUser):
    wait_time = between(5, 15)

    @staticmethod
    def orderUnAcceptable(cart):
        total = 0
        for item in cart:
            total = total + (item["unitPrice"] * item["quantity"])
        return total > 110

    @task
    def load(self):

        # Setup username and password(both are generated)
        username = "user" + str(randint(0, 1000000))
        password = str(randint(0, 10000000))
        base64string = (
            base64.encodebytes(bytes(("%s:%s" % (username, password)), "utf-8"))
            .decode()
            .strip()
        )

        # Start by visiting MuShop
        self.client.get("/")

        # Register a user
        self.client.post(
            "/api/register",
            headers={"Content-Type": "application/json"},
            json={
                "firstName": "User",
                "lastName": "Name",
                "email": "user@example.com",
                "username": username,
                "password": password,
            },
        )

        # login as the newly registered user
        self.client.post(
            "/api/login", headers={"Authorization": "Basic %s" % base64string}
        )

        # update  profile with shipping address and payment info
        self.client.post(
            "/api/address",
            headers={"Content-Type": "application/json"},
            json={
                "number": "000",
                "street": "000 Example St.",
                "city": "City",
                "postcode": "90630",
                "country": "USA",
            },
        )
        self.client.post(
            "/api/card",
            headers={"Content-Type": "application/json"},
            json={"longNum": "0000000000000000", "expires": "0000", "ccv": "000"},
        )

        # visit the category page
        self.client.get("/category.html")

        # get products from the catalogue over the catalogue API, choose random one to buy.
        catalogue = self.client.get("/api/catalogue").json()
        category_item = choice(catalogue)
        item_id = category_item["id"]

        # Visit product page for the chosen product
        self.client.get("/product.html?id={}".format(item_id))

        # add item to cart
        self.client.post("/api/cart", json={"id": item_id, "quantity": 1})

        # visit the cart page
        self.client.get("/cart.html")

        # Get info for checkout
        cart = self.client.get("/api/cart").json()
        address = self.client.get("/api/address").json()
        card = self.client.get("/api/card").json()

        # Checkout the cart as as order. An order where payment was declined is considered a success.
        with self.client.post(
            "/api/orders",
            headers={"Content-Type": "application/json"},
            catch_response=True,
        ) as response:

            if response.status_code < 400 or (
                response.status_code == 406 and self.orderUnAcceptable(cart)
            ):
                response.success()

        # get orders
        order = self.client.get("/api/orders").json()

        # visit the cart page
        self.client.get("/orders.html")

        # Logout
        self.client.get("/api/logout")

