# Keepalived Databases

## Firewall
Regra aplicada à tag `vrrp-database` (origem e destino), que permite troca de mensagens VRRP do Keepalived para healthchecks.

Para isto foi permitido o protocolo 112 (código IANA para o VRRP).

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hivetown-allow-vrrp-database --description="Allow VRRP between load balancers" --direction=INGRESS --priority=1000 --network=hivetown --action=ALLOW --rules=112 --source-tags=vrrp-database --target-tags=vrrp-database
```
</details>

## Comandos
```bash
sudo tcpdump -i ens4 -nn vrrp

sudo cp -R keepalived/keepalived.conf /etc/keepalived
sudo cp -R newMaster.sh /etc/keepalived
sudo cp -R newSlave.sh /etc/keepalived

cp keepalivedSLAVE.conf keepalived.conf
cp keepalivedMASTER.conf keepalived.conf

mudar o keepalived.conf para o MASTER ou SLAVE
sudo systemctl restart keepalived



cp keepalived/keepalivedMASTER.conf keepalived/keepalived.conf
sudo cp -R keepalived/keepalived.conf /etc/keepalived/
sudo cp -R keepalived/takeover.sh /etc/keepalived/


cp keepalived/keepalivedSLAVE.conf keepalived/keepalived.conf
sudo cp -R keepalived/keepalived.conf /etc/keepalived/
sudo cp -R keepalived/takeover.sh /etc/keepalived/

sudo systemctl restart keepalived

sudo systemctl restart keepalived
```
