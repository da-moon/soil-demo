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
