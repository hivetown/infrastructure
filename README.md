# Infrastructure

## Networking
Foi criada uma rede nova na GCP, a `hivetown`.

Nessa, foram depois criadas as **sub-redes** de cada tipo de componentes: `loadbalancers-eu-west4` (10.0.0.0/22), `servicediscovery-eu-west4` (10.0.4.0/22), `database-backups-us-east1` (10.0.112.0/20), `database-eu-west4` (10.0.128.0/18), e `webservers-eu-west4` (10.0.192.0/18).

Desta forma, para usos futuros, permanece disponível a gama de ips 10.0.8.0/22 até 10.0.108/22.

Como os nomes indicam, estão localizadas em `eu-west4` (Países Baixos) com a excepção da `databases-backups-us-east1`, em `us-east1` (Carolina do Sul)

<details>
<summary>Linhas de comandos equivalente:</summary>

```
gcloud compute networks create hivetown --project=hivetown --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

gcloud compute networks subnets create loadbalancers-eu-west4 --project=hivetown --description=Load\ Balancing\ Network --range=10.0.0.0/22 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4 --enable-private-ip-google-access

gcloud compute networks subnets create servicediscovery-eu-west4 --project=hivetown --description=Service\ Discovery\ Network --range=10.0.4.0/22 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4

gcloud compute networks subnets create database-backups-us-east1 --project=hivetown --description=Database\ Backups\ Network --range=10.0.112.0/20 --stack-type=IPV4_ONLY --network=hivetown --region=us-east1

gcloud compute networks subnets create database-eu-west4 --project=hivetown --description=Databases\ Network --range=10.0.128.0/18 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4

gcloud compute networks subnets create webservers-eu-west4 --project=hivetown --description=Web\ Servers\ Netowork --range=10.0.192.0/18 --stack-type=IPV4_ONLY --network=hivetown --region=europe-west4
```
</details>