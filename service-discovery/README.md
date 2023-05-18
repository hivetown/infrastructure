# Service Discovery

## Docker image
Baseado na imagem [zookeeper](https://hub.docker.com/_/zookeeper) do Docker Hub.

## Criação VM na GCP
Para começar, irá ser criada apenas uma instância, sendo essa um ponto único de falha.

No futuro, se restar tempo, e para que haja o quorum, serão implementadas mais duas instâncias.

A VM encontra-se na região `europe-west4` (Países Baixos), na zona `europe-west4-a`.

É uma máquina, como os load balancers, `e2-small`, e que tem como sistema operativo, também, o Ubuntu 22.04 LTS.

Quanto à interface de rede, foi escolhida a interface da rede `hivetown`, na sub-rede `servicediscovery-eu-west4` (10.0.4.0/22) e foi também removido o IP Externo pois este componente não será exposto à Internet. O ip interno é temporário (personalizado) 10.0.4.2.

Foi também adicionada a tag `ssh` e uma nova `zookeeper`.

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute instances create servicediscovery-1 \
    --project=hivetown \
    --zone=europe-west4-a \
    --machine-type=e2-small \
    --network-interface=private-network-ip=10.0.4.2,subnet=servicediscovery-eu-west4,no-address \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=433774389779-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=ssh,zookeeper \
    --create-disk=auto-delete=yes,boot=yes,device-name=servicediscovery-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230415,mode=rw,size=10,type=projects/hivetown/zones/europe-west4-a/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any \
    --deletion-protection
```
</details>

## Firewall
Criadas duas regras de firewall:
1. Aplicada aos clientes, que permite a saída de tráfego dos `zookeeper-client` (tag de rede) para a subrede servicediscovery-eu-west4 do `tcp:2181` (porta do zookeeper)
<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hivetown-allow-zookeeper-client --description="Allow outbound zookeeper client traffic" --direction=EGRESS --priority=1000 --network=hivetown --action=ALLOW --rules=tcp:2181 --destination-ranges=10.0.4.0/22 --target-tags=zookeeper-client
```
</details>

2. Aplicada aos servidores, que permite a entrada de tráfego para os `zookeeper-server` (tag de rede)
<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hivetown-allow-zookeeper-server --description="Allow inbound server traffic" --direction=INGRESS --priority=1000 --network=hivetown --action=ALLOW --rules=tcp:2181 --destination-ranges=10.0.4.0/22 --source-tags=zookeeper-client --target-tags=zookeeper-server
```
</details>
</details>