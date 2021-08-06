export container_name="cloud-lab"
export profile="cloud-lab"
lxc launch \
  --profile="default" \
  --profile="${profile}" \
  images:debian/buster/cloud \
  "${container_name}"  \
