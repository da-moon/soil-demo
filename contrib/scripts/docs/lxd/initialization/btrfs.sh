lxd init \
  --auto \
  --network-address="0.0.0.0" \
  --network-port="8443" \
  --trust-password="$(whoami)" \
  --storage-backend="btrfs" \
  --storage-create-loop="60" \
  --storage-pool="default"
