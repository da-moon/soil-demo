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
