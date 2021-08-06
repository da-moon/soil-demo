inventory="staging"
tags="01-ansible-controller"
# ────────────────────────────────────────────────────────────────────────────────
ansible-playbook \
  -i "${inventory}" \
  --tags "${tags}" \
  site.yml
