from typing import AnyStr, Dict
from requests import post, delete, Response, RequestException

class Haproxy:
    """Haproxy class
    
    This class is responsible for sending commands to the haproxy dataplane api
    """
    def __init__(self, address: AnyStr, username: AnyStr, password: AnyStr) -> None:
        self.address = address
        self.username = username
        self.password = password

    def addServer(self, server: AnyStr, backend: AnyStr) -> Response:
        try:
            serverIp, serverPort = server.split(":")
            serverPort = int(serverPort)

            server = {
                "name": server,
                "address": serverIp,
                "port": serverPort,
                "check": "enabled",
                "check_http_send": "HEAD / HTTP/1.1",
                "observe": "layer7",
                "maintenance": "disabled"
            }

            return self.post(f'/v2/services/haproxy/runtime/servers?backend={backend}', server)
        except RequestException as e:
            return None
        except Exception as e:
            return None

    def removeServer(self, server: AnyStr, backend: AnyStr) -> Response:
        return self.delete(f'/v2/services/haproxy/runtime/servers/{server}?backend={backend}')

    def post(self, endpoint: AnyStr, data: Dict) -> Response:
        return post(f'{self.address}{endpoint}', json=data, auth=(self.username, self.password))
    
    def delete(self, endpoint: AnyStr) -> Response:
        return delete(f'{self.address}{endpoint}', auth=(self.username, self.password))