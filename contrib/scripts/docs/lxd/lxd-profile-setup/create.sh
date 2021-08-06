export profile="cloud-lab"
! lxc profile show "${profile}" > /dev/null 2>&1 && lxc profile create "${profile}"
