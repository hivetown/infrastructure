# Copy .env files
cp .env.example .env
# api.env, for now, already has the correct values predefined
cp api.env.example api.env

# Get ens4 IP
IP=$(ip addr show ens4 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# Replace IP in .env file on MACHINE_IP variable
sed -i "s/MACHINE_IP=.*/MACHINE_IP=$IP/" .env
