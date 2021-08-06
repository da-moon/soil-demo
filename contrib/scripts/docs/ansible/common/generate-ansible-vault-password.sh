passwd_file="${HOME}/.vault_pass.txt"
# ────────────────────────────────────────────────────────────────────────────────
echo \
  -n "$(dd if=/dev/urandom bs=64 count=1 status=none | base64)" \
  | tee ${passwd_file} > /dev/null
