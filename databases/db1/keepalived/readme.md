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