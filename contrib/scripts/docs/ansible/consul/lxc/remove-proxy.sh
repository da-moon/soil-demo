name="consul-server-1" ;
# ────────────────────────────────────────────────────────────────────────────────
lxc config \
  device remove \
  "${name}" "proxy-${name}" ;
# ────────────────────────────────────────────────────────────────────────────────
