from kazoo.client import KazooClient
from dotenv import load_dotenv
from os import getenv
from typing import Set, List, AnyStr
from Haproxy import Haproxy
from RepeatTimer import RepeatTimer
from datetime import datetime

haproxy = Haproxy(getenv("HAPROXY_ADDRESS"), getenv("HAPROXY_USERNAME"), getenv("HAPROXY_PASSWORD"))
def applyTransaction():
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    transaction = haproxy.transaction
    if transaction is None:
        print(f'No transaction to apply at {now}')
        return
    
    res = haproxy.commitTransaction()
    print(f'Transaction {transaction} {"SUCCESS" if res else "FAIL"} at {now}')


repeatTimer = RepeatTimer(5, applyTransaction)

def addToBackend(nodes: Set, backend: AnyStr, transaction: AnyStr):
    for node in nodes:
        print(f'Adding node {node} to backend {backend}')
        haproxy.addServer(node, backend, transaction)

def removeFromBackend(nodes: Set, backend: AnyStr, transaction: AnyStr):
    for node in nodes:
        print(f'Removing node {node} from backend {backend}')
        haproxy.removeServer(node, backend, transaction)

def createdRemoved(childrenBefore: Set, childrenNow: List):
    childrenSet = set(childrenNow)

    # Get nodes created and deleted
    created = childrenSet - childrenBefore
    removed = childrenBefore - childrenSet

    return created, removed

def updateChildren(created: Set, removed: Set, backend: AnyStr):
    transaction = haproxy.getTransaction()
    print(f'Transaction: {transaction}')
    addToBackend(created, backend, transaction)
    removeFromBackend(removed, backend, transaction)

apiChildren = set()
webChildren = set()

def main():
    # Wait for HaProxy Data Plane API to be ready
    haproxy.waitReady()

    hosts = getenv("ZOOKEEPER_HOSTS")

    zookeeper = KazooClient(hosts=hosts)
    zookeeper.start()

    zookeeper.ensure_path("/api-servers")
    zookeeper.ensure_path("/web-servers")

    apiChildren = set(zookeeper.get_children("/api-servers"))
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
            webChildren = childrenSet

    repeatTimer.start()
    try:
        # Wait forever
        while True:
            pass
    except Exception:
        pass

    # Stop whatever is running
    repeatTimer.cancel()
    zookeeper.stop()
    zookeeper.close()

if __name__ == "__main__":
    print('Starting service discovery: ', __name__)

    load_dotenv()
    main()
