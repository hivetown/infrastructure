# Load Balancers

## Criação VMs na GCP

### Master

Criada a máquina `loadbalancer-master`, em `europe-west4-a` (Países Baixos).

É uma máquina `e2-small`, que executa `Ubuntu 22.04 LTS`.

Foi permitido tráfego *HTTP* e *HTTPS*.

Foi eliminada a interface de rede *default* e foi adicionada uma nova interface:
> **Rede**: `hivetown`
> 
> **Sub-rede**: `loadbalancers-eu-west4` (10.0.0.0/22)
> 
> **Zona**: `europe-west4-a`
> 
> **IP principal interno**: Temporário (personalizado): `10.0.0.2`
> 
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

**TODO**:
- SCOPES É PRECISO SER PERMISSÕES FULL PARA A GCP API
- LIMITAR ERA BEM PENSADO!!!
- LIMITAR FIREWALL DOS loadbalancers para apenas trafego vrrp naqueles 2 entre 10.0.0.2 e 10.0.0.3

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

#### Instalação do Docker
Ver [tutorial da DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04#step-1-installing-docker)

#### Instalação do Keepalived

Instalar o keepalived
`sudo apt-get install keepalived`

Iniciar o keepalived quando a VM inicia
`sudo systemctl enable keepalived`

Iniciar o keepalived imediatamente
`sudo systemctl start keepalived`

Depois, foram copiados os ficheiros de configuração de cada tipo:
```bash
# Máquina MASTER
sudo cp -R keepalived/master/* /etc/keepalived

# Máquina BACKUP
sudo cp -R keepalived/backup/* /etc/keepalived
```

Finalmente, reinicia-se o keepalived para que os ficheiros se configuração sejam usados:
`sudo systemctl restart keepalived`

### Backup
Após a configuração do Master foi possível criar uma máquina semelhante (usando a interface da Console do GCP).

Alterações a notar:
> **Nome**: `loadbalancer-backup`
> 
> **Zona**: `europe-west4-b`
> 
> **Endereço principal interno**: Temporário (personalizado): `10.0.0.3`
> 
> **Endereço IPv4 externo**: Nenhum

Foi novamente necessário instalar o Docker

## IP Externo (Floating IP)
Foi reservado um IP externo estático (34.90.28.85) para a região `europe-west4`, associado por defeito ao `loadbalancer-master`

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute addresses create hivetown-external --project=hivetown --region=europe-west4

gcloud compute instances add-access-config loadbalancer-master --project=hivetown --zone=europe-west4-a --address=34.90.28.85
```
</details>

Este IP será, posteriormente, "flutuado", apontando sempre para o balanceador de carga ativo no momento. Essa operação de troca é o takeover, executando quando o balanceador passivo deteta uma falha no ativo e troca de estado (feito pelo keepalived).
