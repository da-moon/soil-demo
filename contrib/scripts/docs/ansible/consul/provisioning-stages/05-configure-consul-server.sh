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
