#!/bin/bash
# Necessary environment variables:
# - $HVT_PUBLIC_IP: the public IP address
# - $INSTANCE_NAME: the name of the host instance
# - $INSTANCE_ZONE: the zone of the host instance
. ./loadEnv.sh

# Get the instance that holds the public IP address - the one that is currently ACTIVE
activeInstance=`gcloud compute instances list --project hivetown | grep $HVT_PUBLIC_IP`
activeInstanceName=`echo $activeInstance | awk '{print $1}'`
activeInstanceZone=`echo $activeInstance | awk '{print $2}'`

# Unassign peer's IP aliases. Try it until it's possible.
gcloud compute instances delete-access-config $activeInstanceName --zone=$activeInstanceZone --access-config-name="External NAT" > /etc/keepalived/takeover.log 2>&1

sleep 1

# Assign IP aliases to me because now I am the MASTER!
until gcloud compute instances add-access-config $INSTANCE_NAME --zone=$INSTANCE_ZONE --address=$HVT_PUBLIC_IP --access-config-name="External NAT" >> /etc/keepalived/takeover.log 2>&1; do
 echo "Instance not accessible during takeover. Retrying in 1 second..."
 sleep 1
done

echo "I became the MASTER at: $(date)" >> /etc/keepalived/takeover.log