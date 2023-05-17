# Load Balancers

## Criação VMs na GCP

### Master (ativo)

Criada a máquina `loadbalancer-1`, em `europe-west4-a` (Países Baixos).

É uma máquina `e2-small`, que executa `Ubuntu 22.04 LTS` (alterado em **Disco de inicialização**).

Foi necessário definir os escopos de acesso:
- Compute Engine: Leitura e gravação

#### Rede
Foram adicionadas as tags de rede `ssh`, `vrrp`, e `http-server`

Foi eliminada a interface de rede *default* e foram adicionadas as seguintes interfaces:
1. loadbalancer-eu-west4
    > **Rede**: `hivetown-external`

    > **Sub-rede**: `loadbalancer-eu-west4` (10.255.0.0/20)
    > 
    > **IP principal interno**: Temporário (personalizado): `10.255.0.2`
    > 
    > **Endereço IPv4 externo**: Nenhum
2. loadbalancers-eu-west4
    > **Rede**: `hivetown`
    > 
    > **Sub-rede**: `loadbalancers-eu-west4` (10.0.0.0/22)
    > 
    > **IP principal interno**: Temporário (automático)
    > 
    > **Endereço IPv4 externo**: Nenhum

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute instances create loadbalancer-1 \
    --project=hivetown \
    --zone=europe-west4-a \
    --machine-type=e2-small \
    --network-interface=private-network-ip=10.255.0.2,subnet=loadbalancer-eu-west4,no-address \
    --network-interface=private-network-ip=10.0.0.2,subnet=loadbalancers-eu-west4,no-address \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=433774389779-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append \
    --tags=ssh,vrrp-loadbalancer,zookeeper-client,http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=loadbalancer-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230415,mode=rw,size=10,type=projects/hivetown/zones/europe-west4-a/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any \
    --deletion-protection
```
</details>


Neste último, no endereço externo, foi propositadamente escolhido "nenhum" pois irá ser criado um **IP Externo** posteriormente.

Porém, isto levanta um problema. Como não existe um endereço externo, não é possível conectar a máquina à internet.
Para isso, foi criado um **Cloud NAT**, porém este não permite gerar uma linha de comandos equivalente.
> **Nome**: `hivetown-nat`
> 
> **Rede**: `hivetown`
> 
> **Região**: `europe-west4`
> 
> **Cloud Router**: (criado um novo router) `hivetown-eu-west4-router`

E o mesmo para a rede `hivetown-external`

Como a interface default é a externa, é necessário adicionar uma rota para que os pacotes direcionados à rede interna (pois apenas são aceites para a subrede dos load balancers) sejam redirecionados para a interface interna:
```bash
sudo ip route add 10.0.0.0/8 via 10.0.0.1
```

Para automatizar, este *script* foi definido como script de inicialização na VM na criação da mesma
#### Instalação do Docker
Ver [tutorial da DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04#step-1-installing-docker)

Para facilitar, foi criado um [gist](https://gist.github.com/luckspt/844520409d7410d5a7b0e8f153d8e7e0) que inclui um script para instalar o docker (e também um para o keepalived) que automatiza este processo
#### Instalação do Keepalived
<details>
<summary>É possível usar um script referido acima, ou da forma manual:</summary>

```bash
# Instalar o keepalived
sudo apt-get install keepalived

# Iniciar o keepalived quando a VM inicia
sudo systemctl enable keepalived

# Iniciar o keepalived imediatamente
sudo systemctl start keepalived
```
</details>

Depois, foram copiados os ficheiros de configuração de cada tipo:
```bash
# Máquina MASTER
sudo cp -R keepalived/master/* /etc/keepalived

# Máquina BACKUP
sudo cp -R keepalived/backup/* /etc/keepalived
```

Finalmente, reinicia-se o keepalived para que os ficheiros se configuração sejam usados:
```bash
sudo systemctl restart keepalived
```

### Backup (passivo)
Após a configuração do Master (ativo) foi necessário criar uma máquina com características idênticas, substituíndo o nome (`loadbalancer-2`, os ips internos `10.0.0.3` e `10.255.0.3`), e a região (`europe-west4-b`):

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute instances create loadbalancer-2 \
    --project=hivetown \
    --zone=europe-west4-b \
    --machine-type=e2-small \
    --network-interface=private-network-ip=10.255.0.3,subnet=loadbalancer-eu-west4,no-address \
    --network-interface=private-network-ip=10.0.0.3,subnet=loadbalancers-eu-west4,no-address \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=433774389779-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append \
    --tags=ssh,vrrp-loadbalancer,zookeeper-client,http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=loadbalancer-2,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230415,mode=rw,size=10,type=projects/hivetown/zones/europe-west4-b/diskTypes/pd-balanced \
    --metadata=startup-script='sudo ip route add 10.0.0.0/8 via 10.0.0.1'
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any \
    --deletion-protection
```
</details>

Foi novamente necessário instalar o Docker

## IP Externo (Floating IP)
Foi reservado um IP externo estático (34.90.28.85) para a região `europe-west4`, associado por defeito ao `loadbalancer-1`

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute addresses create hivetown-external --project=hivetown --region=europe-west4

gcloud compute instances add-access-config loadbalancer-1 --project=hivetown --zone=europe-west4-a --address=34.90.28.85
```
</details>

Este IP será, posteriormente, "flutuado", apontando sempre para o balanceador de carga ativo no momento. Essa operação de troca é o takeover, executando quando o balanceador passivo deteta uma falha no ativo e troca de estado (feito pelo keepalived).
