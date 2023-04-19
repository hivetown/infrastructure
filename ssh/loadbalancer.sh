gcloud compute ssh --zone "europe-west4-$2" "ubuntu@loadbalancer-$1" --tunnel-through-iap --project "hivetown"
