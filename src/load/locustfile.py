import base64

from locust import HttpLocust, TaskSet, task
from random import randint, choice


class WebTasks(TaskSet):

    @task
    def load(self):
        base64string = base64.encodestring('%s:%s' % ('user', 'password')).replace('\n', '')

        catalogue = self.client.get("/api/catalogue").json()
        category_item = choice(catalogue)
        item_id = category_item["id"]

        self.client.get("/")
        self.client.get("/api/login", headers={"Authorization":"Basic %s" % base64string})
        self.client.get("/category.html")
        self.client.get("/product.html?id={}".format(item_id))
        self.client.delete("/api/cart")
        self.client.post("/api/cart", json={"id": item_id, "quantity": 1})
        self.client.get("/cart.html")
        # self.client.post("/orders")
        self.client.get('/api/logout')


class Web(HttpLocust):
    task_set = WebTasks
    min_wait = 0
    max_wait = 0
