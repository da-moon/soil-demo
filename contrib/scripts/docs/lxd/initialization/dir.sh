sudo lxd init \
  --auto \
  --network-address="0.0.0.0" \
  --network-port="8443" \
  --trust-password="$(whoami)" \
  --storage-backend="dir"
