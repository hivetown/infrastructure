# Keepalived Loadbalancers

## Firewall
Regra aplicada à tag `vrrp-loadbalancer` (origem e destino), que permite troca de mensagens VRRP do Keepalived para healthchecks.

Para isto foi permitido o protocolo 112 (código IANA para o VRRP).

<details>
<summary>Linha de comandos equivalente</summary>

```bash
gcloud compute --project=hivetown firewall-rules create hivetown-allow-vrrp-loadbalancers --description="Allow VRRP between load balancers" --direction=INGRESS --priority=1000 --network=hivetown --action=ALLOW --rules=112 --source-tags=vrrp-loadbalancer --target-tags=vrrp-loadbalancer
```
</details>