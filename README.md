# Infrastructure

## Networking

### Rede
Foi criada uma rede nova na GCP, a `hvt`.

Depois, foram criadas as seguintes sub-redes:
- `external-eu-west4` (10.0.0.0/21 2046 hosts) - Tráfego (HTTP(s)) da Internet para os *load balancers*
  - Composta por *load balancers*
  - Limita a 2046 *load balancers*
- `loadbalancer-vrrp-eu-west4` (10.0.8.0/21 2046 hosts) - Tráfego (VRRP) entre *load balancers*
  - Composta por *load balancers*
  - Limita a 2046 *load balancers*
- `database-vrrp-replication-eu-west4` (10.0.16.0/21 2046 hosts) - Tráfego (VRRP e Replicação) entre *databases*
  - Composta por *databases*
  - Limita a 2046 *databases* (sub-rede composta por *databases*)
- `loadbalancer-servicediscovery-eu-west4` (10.0.32.0/20 4094 hosts) - Tráfego (???) dos *load balancers* para *service discovery*
  - Composta por *load balancers* e *service discovery*
  - Removendo aos 4094 hosts os 2046 *load balancers*, esta sub-rede limita à existência de 2048 máquinas *service discovery*
- `webserver-servicediscovery-eu-west4` (10.0.64.0/19 8190 hosts) - Tráfego (???) dos *web servers* para *service discovery*
  - Composta por *service discovery* e *web servers*
  - É necessário ter em atenção porque irá limitar a quantidade de *web servers*.
  - Ora, removendo os 2048 *service discovery*, 6142 IPs seriam atribuídos aos *web servers*
- `loadbalancer-webserver-eu-west4` (10.0.96.0/19 8190 hosts) - Tráfego (HTTP) dos *load balancers* para os *web servers*
  - Composta por *load balancers* e *web servers*
  - Já é sabido que no máximo haverão 2046 *load balancers* e 6142 *web servers*, totalizando 8188 IPs
  - Ficam assim disponíveis 2 IPs sem propósito definido
- `webserver-database-eu-west4` (10.0.128.0/19 8190 hosts) - Tráfego (???) dos *web servers* para *databases*
  - Composta por *web servers* e *databases*
  - Removendo os 6142 *web servers*, ficam disponíveis 2048 IPs que correspondem à quantidade limite de *databases*
  - Como anteriormente as *databases* foram limitadas a 2046 IPs, ficam também 2 IPs disponíveis sem propósito definido
- `database-backup-eu-west4` (10.0.160.0/21 2046 hosts) - Tráfego (???) entre *databases* e [*database backups*]
  - Composta por *databases*
  - Limita a 2046 *databases*
- `database-backup-us-east1` (10.1.160.0/21 2046 hosts) - Tráfego (???) entre [*databases*] e *database backups*
  - Composta por *database backups*
  - Limita a 2046 *database backups*
  - O mesmo que a anterior, porém na região `us-east1`

Em suma:
- <= 2046 *load balancers*
- <= 2046 *databases*
- <= 2046 *database backups*
- <= 2048 *service discovery*
- <= 6142 *web servers*

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

### Firewall

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
