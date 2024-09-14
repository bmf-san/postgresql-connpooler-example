from locust import HttpUser, TaskSet, task, between
import json
import random

class UserBehavior(TaskSet):
    @task(3)
    def get_products(self):
        with self.client.get("/products", params={"limit": 1000000}, catch_response=True) as response:
            if response.status_code != 200:
                response.failure(f"GET /products failed with status code {response.status_code}")

    @task(1)
    def post_product(self):
        product_data = {
            "name": "Test Product",
            "category_id": random.randint(1, 5),
            "price": 29.99,
            "stock": 10
        }
        with self.client.post("/products/create", data=json.dumps(product_data), headers={"Content-Type": "application/json"}, catch_response=True) as response:
            if response.status_code != 201:
                response.failure(f"POST /products/create failed with status code {response.status_code}")

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)
