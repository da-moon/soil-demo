export container_name="cloud-lab"
lxc exec "${container_name}" -- cloud-init status --wait
