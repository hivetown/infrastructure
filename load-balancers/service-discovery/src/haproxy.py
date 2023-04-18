from typing import AnyStr, Dict
from requests import post, put, delete, Response, RequestException

class Haproxy:
    """Haproxy class
    
    This class is responsible for sending commands to the haproxy dataplane api
    """
    def __init__(self, address: AnyStr, username: AnyStr, password: AnyStr) -> None:
        self.address = address
        self.username = username
        self.password = password

    def getVersion(self) -> int:
        try:
            res = self.post(f'/v2/services/haproxy/configuration/version')
            txt = res.text()
            return int(txt)
        except Exception:
            return None

    def createTransaction(self, version: int) -> AnyStr:
        try:
            res = self.post(f'/v2/services/haproxy/transactions?version={version}')
            json = res.json()
            return json['id']
        except Exception:
            return None
    
    def commitTransaction(self, transaction: AnyStr) -> bool:
        try:
            res = self.post(f'/v2/services/haproxy/transactions/{transaction}')
            json = res.json()
            return json['status'] == 'success'
        except Exception:
            return False

    def addServer(self, server: AnyStr, backend: AnyStr, transaction: AnyStr) -> bool:
        try:
            serverIp, serverPort = server.split(":")
            serverPort = int(serverPort)

            server = {
                "name": server,
                "address": serverIp,
                "port": serverPort,
                "check": "enabled",
            }

            self.post(f'/v2/services/haproxy/configuration/servers?backend={backend}&transaction_id={transaction}', server)
            return True
        except Exception:
            return False

    def removeServer(self, server: AnyStr, backend: AnyStr, transaction: AnyStr) -> Response:
        try:
            self.delete(f'/v2/services/haproxy/runtime/servers/{server}?backend={backend}&transaction_id={transaction}')
            return True
        except Exception:
            return False

    def post(self, endpoint: AnyStr, data: Dict) -> Response:
        return post(f'{self.address}{endpoint}', json=data, auth=(self.username, self.password))
    
    def put(self, endpoint: AnyStr, data: Dict) -> Response:
        return put(f'{self.address}{endpoint}', json=data, auth=(self.username, self.password))
    
    def delete(self, endpoint: AnyStr) -> Response:
        return delete(f'{self.address}{endpoint}', auth=(self.username, self.password))