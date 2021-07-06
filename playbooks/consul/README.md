# consul-lab

## Snippets

- check connectivity

```bash
ansible -i staging -m ping all -vvv
```

- Generate a random password to encrypt data with `ansible-vault` and
store it in `~/.vault_pass.txt`.This file already exists in the
Vagrant box so there is no need to run it if your
Ansible controller is the Vagrant box.

```bash
echo \
  -n "$(dd if=/dev/urandom bs=64 count=1 status=none | base64)" \
  | tee ~/.vault_pass.txt
```

- in case your host machine is a remote server (lxd is running on remote), use
the following snippet on host to redirect all connections to port `8500`
to a Consul server's container

```bash
lxc config device \
add "consul-server-1" "proxy-consul-server-1" \
proxy listen=tcp:0.0.0.0:8500 connect=tcp:127.0.0.1:8500
```

remove the proxy with the following snippet :

```bash
lxc config device remove "consul-server-1" "proxy-consul-server-1"
```

- set host environment variables by adding them to bashrc ~/.bashrc

```bash
sed -i '/CONSUL/d' ~/.bashrc && \
cat << EOF | tee -a ~/.bashrc
export CONSUL_HTTP_ADDR="http://$(lxc list --format json \
| jq -r ".[] \
  | select((.name | contains(\"consul\")) and (.status==\"Running\"))" \
| jq -r '.state.network.eth0.addresses' \
| jq -r '.[] | select(.family=="inet").address' | head -n 1):8500"
export CONSUL_SCHEME=http
export CONSUL_HTTP_SSL=false
export CONSUL_HTTP_TOKEN="$(find -name default_policy_token.yml \
| xargs -I {} cat {} \
| yq -r .default_policy_token \
| ansible-vault view --vault-password-file ~/.vault_pass.txt -)"
EOF
```

- decrypt  `consul_root_token`

```bash
find -name consul_root_token.yml | xargs -I {} ansible localhost \
  -m debug \
  -a var="consul_root_token" \
  -e "@{}" \
  --vault-password-file ~/.vault_pass.txt
```


- decrypt  `default_policy_token`

```bash
find -name default_policy_token.yml | xargs -I {} ansible localhost \
  -m debug \
  -a var="default_policy_token" \
  -e "@{}" \
  --vault-password-file ~/.vault_pass.txt
```

- Setup Ansible Controller Software

```bash
ansible-playbook \
  -i staging \
  --tags 01-ansible-controller \
  site.yml
```

- Setup base dependencies for all inventory hosts

```bash
ansible-playbook \
  -i staging \
  --tags 02-install-prerequisites \
  site.yml
```

- install Consul

```bash
ansible-playbook \
  -i staging \
  --limit staging-servers \
  --tags 03-install-consul \
  site.yml
```

- generate certificates for Consul Server

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging-servers \
  --tags 04-consul-certificates \
  site.yml
```

- configure Consul Server

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging-servers \
  --tags 05-configure-consul-server \
  site.yml
```

- test consul kv

```bash
consul kv put -base64 "foo/bar)" "$(base64 <<< $(jq -n \
  --arg time "$(date +'%Y-%m-%d-%H-%M-%S')" \
  --arg value "value is local to project" \
  '{"time":$time,"value":$value}'))"
```
