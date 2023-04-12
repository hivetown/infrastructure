# Load Balancers

## Criação VMs na GCP

### Master

Criada a máquina `load-balancer-master`, nos em `europe-west4-a` (Países Baixos).

É uma máquina `e2-small`, que executa `Ubuntu 22.04 LTS`.

Foi permitido tráfego *HTTP* e *HTTPS*.

Foi eliminada a interface de rede *default* e foi adicionada uma nova interface:
> **Rede**: hivetown
> **Sub-rede**: loadbalancers-eu-west4 IPv4 (10.0.0.0/22)
> **IP principal interno**: Temporário (personalizado): `10.0.0.2`
> **Endereço IPv4 externo**: Nenhum

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute instances create loadbalancer-master \
    --project=hivetown \
    --zone=europe-west4-a \
    --machine-type=e2-small \
    --network-interface=private-network-ip=10.0.0.2,subnet=loadbalancers-eu-west4,no-address \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=433774389779-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=http-server,https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=load-balancer-master,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230302,mode=rw,size=10,type=projects/hivetown/zones/europe-west4-a/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any
```
</details>

Neste último, no endereço externo, foi propositadamente escolhido nenhum pois irá ser criado um **Floating IP** (10.0.0.1) que será então exposto à Internet.

Porém, isto levanta um problema. Como não existe um endereço externo, não é possível conectar a máquina à internet.
Para isso, foi criado um **Cloud NAT**, porém este não permite gerar uma linha de comandos equivalente.
> **Nome**: hivetown-nat
> **Rede**: hivetown
> **Região**: europe-west4
> **Cloud Router**: (criado um novo router) hivetown-eu-west4-router
