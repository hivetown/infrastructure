from kazoo.client import KazooClient
from dotenv import load_dotenv
from os import getenv
from typing import AnyStr

def main():
    hosts = getenv("ZOOKEEPER_HOSTS")
    webPort = getenv("WEB_PORT")
    apiPort = getenv("API_PORT")
    machineIp = getenv("MACHINE_IP")

    zookeeper = KazooClient(hosts=hosts)
    zookeeper.start()

    zookeeper.ensure_path("/api-servers")
    zookeeper.ensure_path("/web-servers")

    zookeeper.create(f'/api-servers/{machineIp}:{apiPort}', ephemeral=True)
    zookeeper.create(f'/web-servers/{machineIp}:{webPort}', ephemeral=True)

    try:
        # Sleep forever
        while True:
            pass
    except Exception:
        pass

    zookeeper.stop()
    zookeeper.close()

if __name__ == "__main__":
    load_dotenv()
    main()
