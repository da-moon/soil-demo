inventory="staging"
tags="02-install-prerequisites"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  --tags "${tags}" \
  site.yml
