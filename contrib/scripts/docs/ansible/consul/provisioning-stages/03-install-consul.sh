inventory="staging"
hosts="staging-servers"
tags="03-install-consul"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  --limit "${hosts}" \
  --tags "${tags}" \
  site.yml
