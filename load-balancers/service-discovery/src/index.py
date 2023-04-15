from kazoo.client import KazooClient
from dotenv import load_dotenv
from os import getenv

def removeFromBackend(backend, nodes):
    for node in nodes:
        print(f'Removing node {node} from backend {backend}')

def addToBackend(backend, nodes):
    for node in nodes:
        print(f'Adding node {node} to backend {backend}')

print('Starting service discovery: ', __name__)
if __name__ == "__main__":
    load_dotenv()

    hosts = getenv("ZOOKEEPER_HOSTS")

    zk = KazooClient(hosts=hosts)
    zk.start()

    zk.ensure_path("/api-servers")
    # TODO implement for web-servers
    # zk.ensure_path("/web-servers")

    apiChildren = set(zk.get_children("/api-servers"))
    addToBackend("hvt-api", apiChildren)

    @zk.ChildrenWatch("/api-servers")
    def watchApiChildren(children):
        global apiChildren
        childrenSet = set(children)

        # Get nodes created and deleted
        created = set(children) - set(apiChildren)
        addToBackend("hvt-api", created)
        removed = set(apiChildren) - set(children)
        removeFromBackend("hvt-api", removed)

        apiChildren = childrenSet.copy()
            
    try:
        # Wait forever
        while True:
            pass
    except Exception:
        pass

    # Stop the ZooKeeper client
    zk.stop()
    zk.close()
