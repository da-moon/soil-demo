export container_name="cloud-lab"
if ! command -- jq -h >/dev/null 2>&1; then
  echo >&2 "*** please install jq before running this snippet".
  exit 1
fi
ip=$(lxc list --format json | jq -r ".[]
| select(
  (.name==\"${container_name}\")
  and (.status==\"Running\")
)
|.state.network.eth0.addresses
|.[]
|select(.family==\"inet\").address")
echo >&2 "*** '$container_name' IP detected : $ip. copying ssh key"
echo >&2 "*** removing Pexisting '$container_name' config from ~/.ssh/config"
sed -n -i "/${container_name}/,/UserKnownHostsFile/!{//!p}" ~/.ssh/config || true
echo >&2 "*** storing ssh config for '$container_name' in ~/.ssh/config"
cat << EOF | tee -a ~/.ssh/config > /dev/null
Host ${container_name}
  user $(whoami)
  HostName ${ip}
  RequestTTY yes
  IdentityFile ~/.ssh/${container_name}_id_rsa
  IdentitiesOnly yes
  StrictHostKeyChecking no
  CheckHostIP no
  MACs hmac-sha2-256
  UserKnownHostsFile /dev/null
EOF
