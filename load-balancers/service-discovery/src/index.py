from kazoo.client import KazooClient
from dotenv import load_dotenv
from os import getenv
from typing import Set, List, AnyStr
from haproxy import Haproxy

haproxy = Haproxy(getenv("HAPROXY_ADDRESS"), getenv("HAPROXY_USERNAME"), getenv("HAPROXY_PASSWORD"))

def addToBackend(nodes: Set, backend: AnyStr):
    for node in nodes:
        print(f'Adding node {node} to backend {backend}')
        print(haproxy.addServer(node, backend).json())

def removeFromBackend(nodes: Set, backend: AnyStr):
    for node in nodes:
        print(f'Removing node {node} from backend {backend}')
        haproxy.removeServer(node, backend)

def handleChildrenChange(childrenBefore: Set, childrenNow: Set, backend: AnyStr):
    childrenSet = set(childrenNow)

    # Get nodes created and deleted
    created = childrenSet - childrenBefore
    removed = childrenBefore - childrenSet
    addToBackend(created, backend)
    removeFromBackend(removed, backend)

apiChildren = set()
webChildren = set()

def main():
    hosts = getenv("ZOOKEEPER_HOSTS")

    zookeeper = KazooClient(hosts=hosts)
    zookeeper.start()

    zookeeper.ensure_path("/api-servers")
    zookeeper.ensure_path("/web-servers")

    apiChildren = set(zookeeper.get_children("/api-servers"))
    print(f'API children1: {apiChildren}')
    webChildren = set(zookeeper.get_children("/web-servers"))
    if len(apiChildren) > 0:
        addToBackend(apiChildren, "hvt-api")
    if len(webChildren) > 0:
        addToBackend(webChildren, "hvt-web")

    @zookeeper.ChildrenWatch("/api-servers")
    def watchApiChildren(children: List):
        global apiChildren
        childrenSet = set(children)
        handleChildrenChange(apiChildren, childrenSet, "hvt-api")
        apiChildren = childrenSet

    @zookeeper.ChildrenWatch("/web-servers")
    def watchWebChildren(children: List):
        global webChildren
        childrenSet = set(children)
        handleChildrenChange(webChildren, childrenSet, "hvt-web")
        webChildren = childrenSet
            
    try:
        # Wait forever
        while True:
            pass
    except Exception:
        pass

    # Stop the ZooKeeper client
    zookeeper.stop()
    zookeeper.close()

if __name__ == "__main__":
    print('Starting service discovery: ', __name__)

    load_dotenv()
    main()
