# Infrastructure

## Networking

### Rede
Foram criadas novas redes VPC na GCP, a `hivetown` e a `hivetown-external`.

#### `hivetown`
Esta VPC foi então repartida em sub-redes, para ajudar na organização e reserva de endereços para cada tipo de componente:
- `loadbalancers-eu-west4` (10.0.0.0/22)
- `servicediscovery-eu-west4` (10.0.4.0/22)
- `database-backups-us-east1` (10.0.112.0/20)
- `database-eu-west4` (10.0.128.0/18)
- `webservers-eu-west4` (10.0.192.0/18)

Como os nomes indicam, estão localizadas em `eu-west4` (Países Baixos) com a excepção da `database-backup-us-east1`, em `us-east1` (Carolina do Sul)

<details>
<summary>Linhas de comandos equivalente:</summary>

```bash
gcloud compute networks create hvt --project=hivetown --description=Hivetown\ Network --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

gcloud compute networks subnets create external-eu-west4 --project=hivetown --description=Tr\áfego\ \(HTTP\(s\)\)\ da\ Internet\ para\ os\ \*load\ balancers\* --range=10.0.0.0/21 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4

gcloud compute networks subnets create loadbalancer-vrrp-eu-west4 --project=hivetown --description=Tr\áfego\ \(VRRP\)\ entre\ \*load\ balancers\* --range=10.0.8.0/21 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4 --enable-private-ip-google-access

gcloud compute networks subnets create database-vrrp-replication-eu-west4 --project=hivetown --description=Tr\áfego\ \(VRRP\ e\ Replica\ç\ão\)\ entre\ \*databases\* --range=10.0.16.0/21 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4 --enable-private-ip-google-access

gcloud compute networks subnets create loadbalancer-servicediscovery-eu-west4 --project=hivetown --description=Tr\áfego\ \(\?\?\?\)\ dos\ \*load\ balancers\*\ para\ \*service\ discovery\* --range=10.0.32.0/20 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4

gcloud compute networks subnets create webserver-servicediscovery-eu-west4 --project=hivetown --description=Tr\áfego\ \(\?\?\?\)\ dos\ \*web\ servers\*\ para\ \*service\ discovery\* --range=10.0.64.0/19 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4

gcloud compute networks subnets create loadbalancer-webserver-eu-west4 --project=hivetown --description=Tr\áfego\ \(HTTP\)\ dos\ \*load\ balancers\*\ para\ os\ \*web\ servers\* --range=10.0.96.0/19 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4

gcloud compute networks subnets create webserver-database-eu-west4 --project=hivetown --description=Tr\áfego\ \(\?\?\?\)\ dos\ \*web\ servers\*\ para\ \*databases\* --range=10.0.128.0/19 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4

gcloud compute networks subnets create database-backup-eu-west4 --project=hivetown --description=Tr\áfego\ \(\?\?\?\)\ entre\ \*databases\*\ e\ \[\*database\ backups\*\] --range=10.0.160.0/21 --stack-type=IPV4_ONLY --network=hvt --region=europe-west4

gcloud compute networks subnets create database-backup-us-east1 --project=hivetown --description=Tr\áfego\ \(\?\?\?\)\ entre\ \[\*databases\*\]\ e\ \*database\ backups\* --range=10.1.160.0/21 --stack-type=IPV4_ONLY --network=hvt --region=us-east1

```
</details>

#### `hivetown-external`
Nesta foi criada uma sub-rede a `loadbalancer-eu-west4` (10.255.0.0/22).

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute networks create hivetown-external --project=hivetown --description=External\ Interface\ for\ Hivetown --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

gcloud compute networks subnets create loadbalancer-eu-west4 --project=hivetown --description=Load\ balancer\ external\ subnet --range=10.255.0.0/22 --stack-type=IPV4_ONLY --network=hivetown-external --region=europe-west4
```
</details>

### Firewall

#### HTTP(s)
Regra aplicada à tag `http-server` da rede `hivetown-external`, que permite à internet de aceder às portas 80 e 433

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hivetown-external-allow-http --direction=INGRESS --priority=1000 --network=hivetown-external --action=ALLOW --rules=tcp:80,tcp:433 --source-ranges=0.0.0.0/0 --target-tags=http-server
```
</details>

#### SSH
Regra aplicada à tag `ssh`, que permite aos administradores do sistema conectarem-se às máquinas em questão.

Para isto foi permitido tcp na porta 22 (porta default ssh).

<details>
<summary>Linha de comandos equivalente:</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hvt-ssh --description="Permitir SSH" --direction=INGRESS --priority=1000 --network=hvt --action=ALLOW --rules=tcp:22 --source-ranges=35.235.240.0/20 --target-tags=ssh
```
</details>

#### VRRP
Regra aplicada à tag `vrrp` (origem e destino), que permite troca de mensagens do Keepalived para healthchecks.

Para isto foi permitido o protocolo 112 (código IANA para o VRRP).

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hvt-vrrp --description="Permitir VRRP" --direction=INGRESS --priority=1000 --network=hvt --action=ALLOW --rules=112 --source-tags=vrrp --target-tags=vrrp
```
</details>

## Mais info
Agora, poderá encontrar descrições mais detalhadas de cada componente no seu próprio README.

Como sugestão, pode seguir a estrutura `load-balancers` -> `service-discovery` -> `web-servers` -> `databases`
> Nota: `web-servers` inclui código aplicacional doutros dois repositórios: hivetown/backend e hivetown/frontend
