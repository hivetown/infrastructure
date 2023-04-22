# Web Servers

## Docker Images
As imagens são definidas (e publicadas no [Docker Hub](https://hub.docker.com)) nos seus próprios repositórios, sendo elas [luckspt/hivetown-api](https://hub.docker.com/r/luckspt/hivetown-api) e [luckspt/hivetown-web](https://hub.docker.com/r/luckspt/hivetown-web).

## Criação VMs na GCP

Para começar, cria-se uma única VM. Depois, criar-se-á uma imagem a partir dessa VM que será então usada para criar máquinas duplicadas dessa mesma.

Esta máquina encontra-se na região `europe-west4` (Países Baixos), na zona `europe-west4-a`.

É uma máquina, como os load balancers, `e2-small`, e que tem como sistema operativo, também, o Ubuntu 22.04 LTS.

Não foi escolhido permitir tráfego HTTP nem HTTPS pois será mais bem definido nas regras da firewall.

Como interfaces de rede, foi também eliminada a interface da rede *default* em detrimento da interface da rede `hivetown`, na sub-rede `webservers-eu-west4` (10.0.192.0/18). Foi também removido o IP Externo pois estes componentes não serão expostos à Internet.
<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute instances create webserver-1 \
    --project=hivetown \
    --zone=europe-west4-a \
    --machine-type=e2-small \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=433774389779-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=http-server,https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=webserver-1,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230411,mode=rw,size=10,type=projects/hivetown/zones/us-central1-a/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any
```
</details>

## Configuração da máquina
Foi instalado o docker, da mesma forma que nos balanceadores de carga, e clonado este repositório.

Nesta diretoria, ao executar o script [run-prod.sh](run-prod.sh) as imagens são executadas em containers e expostas nas portas 8080 e 8081.

## Imagem de Máquina
Assim temos uma máquina genérica dum webserver, podendo agora criar uma imagem de máquina no GCP, possibilitando a criação de máquinas iguais.

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud beta compute machine-images create webserver --project=hivetown --description=Hivetown\ Webserver --source-instance=webserver-1 --source-instance-zone=europe-west4-a --storage-location=eu
```
</details>

### Criação nova instância
Partindo dessa imagem de máquina, cria-se então outra instância.

É importante notar que, por defeito, a nova máquina poderá não ser colocada na zona pretendida.

Para solucionar, altera-se a zona para `europe-west4-b` (Países Baixos).

Por algum motivo, a sub-rede escolhida foi `database-eu-west4` ao invés de `webservers-eu-west4`, como definido na imagem de máquina.
Deve-se confirmar este aspecto.

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute instances create webserver-2 \
    --project=hivetown \
    --zone=europe-west4-b \
    --machine-type=e2-small \
    --network-interface=subnet=webservers-eu-west4,no-address \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=433774389779-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --min-cpu-platform=Automatic \
    --tags=ssh \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=ec-src=vm_add-gcloud \
    --reservation-affinity=any \
    --source-machine-image=webserver
```
</details>