# Copy .env files
if [ ! -f .env ]
then
	cp .env.example .env
fi

if [ ! -f api.env ]
then
	cp api.env.example api.env
fi

if [ ! -f web.env ]
then
	cp web.env.example web.env
fi

# Get ens4 IP
IP=$(ip addr show ens4 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# Replace IP in .env file on MACHINE_IP variable
sed -i "s/MACHINE_IP=.*/MACHINE_IP=$IP/" .env

# Start docker-compose
# make sure to stop if it's already running
docker compose down
docker compose up -d
