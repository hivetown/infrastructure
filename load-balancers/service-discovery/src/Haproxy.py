from typing import AnyStr, Dict
from requests import get, post, put, delete, Response, RequestException
from time import time, sleep
from threading import Lock, Timer

class Haproxy:
    """Haproxy class
    
    This class is responsible for sending commands to the haproxy dataplane api
    """
    def __init__(self, address: AnyStr, username: AnyStr, password: AnyStr) -> None:
        self.address = address
        self.username = username
        self.password = password
        self.ready = False
        self.transaction = None
    
    def waitReady(self) -> bool:
        if self.ready:
            return True
        
        while True:
            try:
                res = self.get('/v2/info')
                if res.status_code == 200:
                    self.ready = True
                    return True
            except RequestException:
                pass

    def getVersion(self) -> int:
        try:
            res = self.get(f'/v2/services/haproxy/configuration/version')
            txt = res.text
            return int(txt)
        except Exception:
            return None

    def createTransaction(self, version: int) -> AnyStr:
        try:
            res = self.post(f'/v2/services/haproxy/transactions?version={version}', None)
            json = res.json()
            return json['id']
        except Exception:
            return None

    # Lazy transaction
    def getTransaction(self) -> AnyStr:
        if self.transaction is None:
            configVersion = self.getVersion()
            self.transaction = self.createTransaction(configVersion)

        return self.transaction
   
    def commitTransaction(self) -> bool:
        """
        :requires: self.transaction is not None
        """
        try:
            res = self.put(f'/v2/services/haproxy/transactions/{self.transaction}', None)
            json = res.json()
            return json['status'] == 'success'
        except Exception:
            return False
        finally:
            # Reset transaction
            self.transaction = None

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
            self.delete(f'/v2/services/haproxy/configuration/servers/{server}?backend={backend}&transaction_id={transaction}')
            return True
        except Exception:
            return False

    def get(self, endpoint: AnyStr) -> Response:
        return get(f'{self.address}{endpoint}', auth=(self.username, self.password))

    def post(self, endpoint: AnyStr, data: Dict) -> Response:
        return post(f'{self.address}{endpoint}', json=data, auth=(self.username, self.password))
    
    def put(self, endpoint: AnyStr, data: Dict) -> Response:
        return put(f'{self.address}{endpoint}', json=data, auth=(self.username, self.password))
    
    def delete(self, endpoint: AnyStr) -> Response:
        return delete(f'{self.address}{endpoint}', auth=(self.username, self.password))
    