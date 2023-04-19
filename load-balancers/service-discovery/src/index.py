from time import sleep
from kazoo.client import KazooClient
from dotenv import load_dotenv
from os import getenv
from typing import Set, List, AnyStr
from haproxy import Haproxy

haproxy = Haproxy(getenv("HAPROXY_ADDRESS"), getenv("HAPROXY_USERNAME"), getenv("HAPROXY_PASSWORD"))

def addToBackend(nodes: Set, backend: AnyStr, transaction: AnyStr):
    for node in nodes:
        print(f'Adding node {node} to backend {backend}')
        haproxy.addServer(node, backend, transaction)

def removeFromBackend(nodes: Set, backend: AnyStr, transaction: AnyStr):
    for node in nodes:
        print(f'Removing node {node} from backend {backend}')
        haproxy.removeServer(node, backend, transaction)

def createdRemoved(childrenBefore: Set, childrenNow: Set):
    childrenSet = set(childrenNow)

    # Get nodes created and deleted
    created = childrenSet - childrenBefore
    removed = childrenBefore - childrenSet

    return created, removed

def updateChildren(created: Set, removed: Set, backend: AnyStr):
    configVersion = haproxy.getVersion()
    print(f'Config version: {configVersion}')
    transaction = haproxy.createTransaction(configVersion)
    print(f'Created transaction: {transaction}')
    addToBackend(created, backend, transaction)
    removeFromBackend(removed, backend, transaction)
    haproxy.commitTransaction(transaction)
    print(f'Committed transaction: {transaction}')

apiChildren = set()
webChildren = set()

def main():
    # Wait for HaProxy Data Plane API to be ready
    haproxy.wait_ready()

    hosts = getenv("ZOOKEEPER_HOSTS")

    zookeeper = KazooClient(hosts=hosts)
    zookeeper.start()

    zookeeper.ensure_path("/api-servers")
    zookeeper.ensure_path("/web-servers")

    apiChildren = set(zookeeper.get_children("/api-servers"))
    print(f'API children1: {apiChildren}')
    webChildren = set(zookeeper.get_children("/web-servers"))
    if len(apiChildren) > 0:
        updateChildren(apiChildren, set(), "hvt-api")
    if len(webChildren) > 0:
        updateChildren(webChildren, set(), "hvt-web")

    @zookeeper.ChildrenWatch("/api-servers")
    def watchApiChildren(children: List):
        global apiChildren
        childrenSet = set(children)
        created, removed = createdRemoved(apiChildren, childrenSet)

        if len(created) > 0 or len(removed) > 0:
            updateChildren(created, removed, "hvt-api")
            apiChildren = childrenSet

    @zookeeper.ChildrenWatch("/web-servers")
    def watchWebChildren(children: List):
        global webChildren
        childrenSet = set(children)
        created, removed = createdRemoved(webChildren, childrenSet)

        if len(created) > 0 or len(removed) > 0:
            updateChildren(created, removed, "hvt-web")
            apiChildren = childrenSet
            
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
