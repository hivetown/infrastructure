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
gcloud compute networks create hivetown --project=hivetown --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

gcloud compute networks subnets create loadbalancers-eu-west4 --project=hivetown --description=Load\ Balancing\ Network --range=10.0.0.0/22 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4 --enable-private-ip-google-access

gcloud compute networks subnets create servicediscovery-eu-west4 --project=hivetown --description=Service\ Discovery\ Network --range=10.0.4.0/22 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4

gcloud compute networks subnets create database-backups-us-east1 --project=hivetown --description=Database\ Backups\ Network --range=10.0.112.0/20 --stack-type=IPV4_ONLY --network=hivetown --region=us-east1

gcloud compute networks subnets create database-eu-west4 --project=hivetown --description=Databases\ Network --range=10.0.128.0/18 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4 --enable-private-ip-google-access

gcloud compute networks subnets create webservers-eu-west4 --project=hivetown --description=Web\ Servers\ Network --range=10.0.192.0/18 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4

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
gcloud compute --project=hivetown firewall-rules create hivetown-allow-ssh --description="Allow SSH" --direction=INGRESS --priority=65534 --network=hivetown --action=ALLOW --rules=tcp:22 --source-ranges=35.235.240.0/20 --target-tags=ssh
```
</details>

#### VRRP
Ver [Keepalived Loadbalancers](../load-balancers/keepalived/README.md) e [Keepalived Bases de Dados](../databases/keepalived/README.md)

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hivetown-allow-vrrp --description="Allow VRRP" --direction=INGRESS --priority=1000 --network=hivetown --action=ALLOW --rules=112 --source-ranges=10.0.0.0/22,10.0.128.0/18 --source-tags=vrrp --target-tags=vrrp
```
</details>

## Mais info
Agora, poderá encontrar descrições mais detalhadas de cada componente no seu próprio README.

Como sugestão, pode seguir a estrutura `load-balancers` -> `service-discovery` -> `web-servers` -> `databases`
> Nota: `web-servers` inclui código aplicacional doutros dois repositórios: hivetown/backend e hivetown/frontend
