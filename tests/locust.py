from locust import HttpUser, task
import time

class testHivetown(HttpUser):
    @task
    def testesBasicos(self):
        self.client.get("")
        self.client.get("produtos")
        self.client.get("produtores")

    # @task(3)
    # def testesProdutos(self):
    #     for item_id in range(10):
    #         self.client.get(f"/produtos?id={item_id}", name="/item")
    #         time.sleep(1)

    # @task(3)
    # def testesProdutores(self):
    #     for item_id in range(10):
    #         self.client.get(f"/produtores?id={item_id}", name="/item")
    #         time.sleep(1)

