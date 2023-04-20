sudo tcpdump -i ens4 -nn vrrp

sudo cp -R keepalived/keepalived.conf /etc/keepalived
sudo cp -R newMaster.sh /etc/keepalived
sudo cp -R newSlave.sh /etc/keepalived

cp keepalivedSLAVE.conf keepalived.conf
cp keepalivedMASTER.conf keepalived.conf

mudar o keepalived.conf para o MASTER ou SLAVE
sudo systemctl restart keepalived