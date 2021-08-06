# consul-lab

## Table of Contents
<!-- AUTO-GENERATED-CONTENT:START (TOC) -->
- [common snippets](#common-snippets)
- [lxc snippets](#lxc-snippets)
- [post-provisioning snippets](#post-provisioning-snippets)
- [provisioning-stages snippets](#provisioning-stages-snippets)
<!-- AUTO-GENERATED-CONTENT:END -->
## common snippets

- check connectivity
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/common/check-connectivity.sh&src=../../contrib/scripts/docs/ansible/common/check-connectivity.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/common/check-connectivity.sh -->
```bash
# -- contrib/scripts/docs/ansible/common/check-connectivity.sh
ansible -i staging -m ping all -vvv
```
<!-- AUTO-GENERATED-CONTENT:END -->
- Generate a random password to encrypt data with `ansible-vault` and
store it in `~/.vault_pass.txt`.This file already exists in the
Vagrant box so there is no need to run it if your
Ansible controller is the Vagrant box.
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/common/generate-ansible-vault-password.sh&src=../../contrib/scripts/docs/ansible/common/generate-ansible-vault-password.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/common/generate-ansible-vault-password.sh -->
```bash
# -- contrib/scripts/docs/ansible/common/generate-ansible-vault-password.sh
passwd_file="${HOME}/.vault_pass.txt"
# ────────────────────────────────────────────────────────────────────────────────
echo \
  -n "$(dd if=/dev/urandom bs=64 count=1 status=none | base64)" \
  | tee ${passwd_file} > /dev/null
```
<!-- AUTO-GENERATED-CONTENT:END -->
## lxc snippets

- in case your host machine is a remote server (lxd is running on remote), use
the following snippet on host to redirect all connections to port `8500`
to a Consul server's container
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/lxc/add-proxy.sh&src=../../contrib/scripts/docs/ansible/consul/lxc/add-proxy.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/lxc/add-proxy.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/lxc/add-proxy.sh
name="consul-1" ;
port="8500" ;
# ────────────────────────────────────────────────────────────────────────────────
lxc config \
  device add \
  "${name}" "proxy-${name}" \
  proxy \
    listen="tcp:0.0.0.0:${port}" \
    connect=tcp:127.0.0.1:${port};
# ────────────────────────────────────────────────────────────────────────────────
```
<!-- AUTO-GENERATED-CONTENT:END -->
- remove the proxy with the following snippet :
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/lxc/remove-proxy.sh&src=../../contrib/scripts/docs/ansible/consul/lxc/remove-proxy.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/lxc/remove-proxy.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/lxc/remove-proxy.sh
name="consul-server-1" ;
# ────────────────────────────────────────────────────────────────────────────────
lxc config \
  device remove \
  "${name}" "proxy-${name}" ;
# ────────────────────────────────────────────────────────────────────────────────
```
<!-- AUTO-GENERATED-CONTENT:END -->

## post-provisioning snippets

- update host environment variables for seamless interaction with Consul cluster
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/post-provisioning/update-profile.sh&src=../../contrib/scripts/docs/ansible/consul/post-provisioning/update-profile.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/post-provisioning/update-profile.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/post-provisioning/update-profile.sh
token_variable_name="default_policy_token"
# ────────────────────────────────────────────────────────────────────────────────
sed -i '/CONSUL/d' ~/.bashrc && \
cat << EOF | tee -a ~/.bashrc
export CONSUL_HTTP_ADDR="http://$(lxc list --format json \
| jq -r ".[] \
  | select((.name | contains(\"consul\")) and (.status==\"Running\"))" \
| jq -r '.state.network.eth0.addresses' \
| jq -r '.[] | select(.family=="inet").address' | head -n 1):8500"
export CONSUL_SCHEME=http
export CONSUL_HTTP_SSL=false
export CONSUL_HTTP_TOKEN="$(find -name ${token_variable_name}.yml \
| xargs -I {} cat {} \
| yq -r ".${token_variable_name}" \
| ansible-vault view --vault-password-file ~/.vault_pass.txt -)"
EOF
source ~/.bashrc
```
<!-- AUTO-GENERATED-CONTENT:END -->
- decrypt  `consul_root_token`
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-consul-root-token.sh&src=../../contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-consul-root-token.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-consul-root-token.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-consul-root-token.sh
passwd_file="${HOME}/.vault_pass.txt"
token_variable_name="consul_root_token"
# ────────────────────────────────────────────────────────────────────────────────
find -name "${token_variable_name}.yml" \
| xargs -r -I {} \
  ansible localhost \
    -m debug \
    -a var="${token_variable_name}" \
    -e "@{}" \
    --vault-password-file "${passwd_file}"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- decrypt  `default_policy_token`
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-default-policy-token.sh&src=../../contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-default-policy-token.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-default-policy-token.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/post-provisioning/decrypt-default-policy-token.sh
passwd_file="${HOME}/.vault_pass.txt"
token_variable_name="default_policy_token"
# ────────────────────────────────────────────────────────────────────────────────
find -name "${token_variable_name}.yml" \
| xargs -r -I {} \
  ansible localhost \
    -m debug \
    -a var="${token_variable_name}" \
    -e "@{}" \
    --vault-password-file "${passwd_file}"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- test consul kv
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/post-provisioning/test-consul-kv.sh&src=../../contrib/scripts/docs/ansible/consul/post-provisioning/test-consul-kv.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/post-provisioning/test-consul-kv.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/post-provisioning/test-consul-kv.sh
path="foo/bar"
# ────────────────────────────────────────────────────────────────────────────────
consul kv put -base64 "${path}" "$(base64 <<< $(jq -n \
  --arg time "$(date +'%Y-%m-%d-%H-%M-%S')" \
  --arg value "sample value" \
  '{"time":$time,"value":$value}'))"
```
<!-- AUTO-GENERATED-CONTENT:END -->
## provisioning-stages snippets

- Setup Ansible Controller Software
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/provisioning-stages/01-ansible-controller.sh&src=../../contrib/scripts/docs/ansible/consul/provisioning-stages/01-ansible-controller.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/provisioning-stages/01-ansible-controller.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/provisioning-stages/01-ansible-controller.sh
inventory="staging"
tags="01-ansible-controller"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  --tags "${tags}" \
  site.yml
```
<!-- AUTO-GENERATED-CONTENT:END -->
- Setup base dependencies for all inventory hosts
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/provisioning-stages/02-install-prerequisites.sh&src=../../contrib/scripts/docs/ansible/consul/provisioning-stages/02-install-prerequisites.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/provisioning-stages/02-install-prerequisites.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/provisioning-stages/02-install-prerequisites.sh
inventory="staging"
tags="02-install-prerequisites"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  --tags "${tags}" \
  site.yml
```
<!-- AUTO-GENERATED-CONTENT:END -->
- install Consul
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/provisioning-stages/03-install-consul.sh&src=../../contrib/scripts/docs/ansible/consul/provisioning-stages/03-install-consul.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/provisioning-stages/03-install-consul.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/provisioning-stages/03-install-consul.sh
inventory="staging"
hosts="staging-servers"
tags="03-install-consul"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  --limit "${hosts}" \
  --tags "${tags}" \
  site.yml
```
<!-- AUTO-GENERATED-CONTENT:END -->
- generate certificates for Consul Server
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/provisioning-stages/04-consul-certificates.sh&src=../../contrib/scripts/docs/ansible/consul/provisioning-stages/04-consul-certificates.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/provisioning-stages/04-consul-certificates.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/provisioning-stages/04-consul-certificates.sh
inventory="staging"
hosts="staging-servers"
tags="04-consul-certificates"
passwd_file="${HOME}/.vault_pass.txt"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  -e vault_password_file="${passwd_file}" \
  --vault-password-file "${passwd_file}" \
  --limit "${hosts}" \
  --tags "${tags}" \
  site.yml
```
<!-- AUTO-GENERATED-CONTENT:END -->
- configure Consul Server
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/ansible/consul/provisioning-stages/05-configure-consul-server.sh&src=../../contrib/scripts/docs/ansible/consul/provisioning-stages/05-configure-consul-server.sh) -->
<!-- The below code snippet is automatically added from ../../contrib/scripts/docs/ansible/consul/provisioning-stages/05-configure-consul-server.sh -->
```bash
# -- contrib/scripts/docs/ansible/consul/provisioning-stages/05-configure-consul-server.sh
inventory="staging"
hosts="staging-servers"
tags="05-configure-consul-server"
passwd_file="${HOME}/.vault_pass.txt"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  -e vault_password_file="${passwd_file}" \
  --vault-password-file "${passwd_file}" \
  --limit "${hosts}" \
  --tags "${tags}" \
  site.yml
```
<!-- AUTO-GENERATED-CONTENT:END -->
