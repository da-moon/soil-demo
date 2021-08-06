export profile="cloud-lab"
cat << PROFILE
config:
  raw.lxc: |
    lxc.apparmor.profile=unconfined
    lxc.mount.auto=proc:rw sys:rw cgroup:rw:force
    lxc.cgroup.devices.allow=a
    lxc.cap.drop=
  security.nesting: "true"
  security.privileged: "true"
  user.user-data: |
    #cloud-config
    users:
      - name: $(whoami)
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        groups: sudo
        shell: /bin/bash
        lock_passwd: false
        passwd: $(openssl passwd -1 -salt SaltSalt $(whoami))
        ssh_authorized_keys:
          - $(cat ~/.ssh/id_rsa.pub)
          - $(cat ~/.ssh/${profile}_id_rsa.pub)
    package_update: true
    package_upgrade: true
    package_reboot_if_required: true
    packages:
      - sudo
      - apt-utils
      - curl
      - wget
      - ca-certificates
      - gnupg2
      - git
      - jq
      - openssh-server
    runcmd:
      - /bin/bash
      - -cex
      - |
        echo "========= cloud-init =========" > /tmp/cloud-init
        if [ ! -r /etc/ssh/sshd_config ] ; then
          echo "sshd_config not found" >> /tmp/sshd-cloud-init
          exit 1
        fi
        sed -i "/.*PasswordAuthentication.*/d" /etc/ssh/sshd_config ;
        echo "PasswordAuthentication no" >>  /etc/ssh/sshd_config ;
        sed -i "/.*PermitRootLogin.*/d" /etc/ssh/sshd_config ;
        echo "PermitRootLogin no" >> /etc/ssh/sshd_config ;
        sed -i "/.*UsePAM.*/d" /etc/ssh/sshd_config ;
        echo "UsePAM no" >> /etc/ssh/sshd_config ;
        sed -i "/.*PubkeyAuthentication.*/d" /etc/ssh/sshd_config ;
        echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config ;
        echo "sshd_config done" >> /tmp/cloud-init ;
        systemctl restart sshd ;
        exit 0 ;
description: ${profile} LXD profile
name: ${profile}
used_by: []
PROFILE
