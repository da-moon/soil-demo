path="foo/bar"
# ────────────────────────────────────────────────────────────────────────────────
consul kv put -base64 "${path}" "$(base64 <<< $(jq -n \
  --arg time "$(date +'%Y-%m-%d-%H-%M-%S')" \
  --arg value "sample value" \
  '{"time":$time,"value":$value}'))"
