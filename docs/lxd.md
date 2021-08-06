# lxc

## Table of Contents
<!-- AUTO-GENERATED-CONTENT:START (TOC) -->
- [overview](#overview)
- [LXC ecosystem](#lxc-ecosystem)
- [workflow](#workflow)
  - [workflow overview](#workflow-overview)
  - [installation](#installation)
  - [initialization](#initialization)
  - [LXD profile setup](#lxd-profile-setup)
  - [container creation](#container-creation)
- [common commands](#common-commands)
- [further reading](#further-reading)
- [references](#references)
<!-- AUTO-GENERATED-CONTENT:END -->
## overview

  [`LXC`](https://linuxcontainers.org) or `Linux Containers` , managed,
developed and maintained by [`Canonical`](https://canonical.com)
refers to a suite of command-line utilities focused on creating and
orchestrating `system containers`, whether they are running in a
standalone environment or a cluster.

  system containers or `OS containers` refer to containerization
technologies that offer an environment as close as possible as the
one you'd get from a `Virtual Machine`, such as `Libvirt`, `Qemu` or
`Oracle Virtualbox` but without the overhead that comes with running
a resource-hungry hypervisor and a separate kernel which simulating
all the hardware.

  In practice, I find `system containers` to offer more freedom and
interactivity compared with `application containers` such as Docker.

  The following is a non-exhaustive list of why I choose to use `LXC` to
provide and set up development environments for repositories:

- ease of use: Personally speaking, I find `LXC` to be much simpler to use
compared with Docker.
- interactivity: `LXC` offers a more significant degree of freedom to
install and run software within its containers since it was meant to be
a replacement, for most cases, to virtual machines. It is pretty easy to
get a shell and run commands the same way you run them in your native OS
shell.
- high-privilege: it is pretty easy to set up `LXC` to run the application
that needs higher privilege, such as access to specific Linux kernel API
or CPU execution ring 2/1 in `LXC`. You can also run nested containers
within `LXC`; for instance, run a Docker container inside the `LXC`
container.
- architecture emulation: it is relatively easy to emulate foreign CPU
architecture inside `LXC` containers. For instance, your host machine
may have `x86_64` architecture, but you are developing for `aarch64`.You
can have the container emulate `aarch64` CPU architecture.
- simple clustering: I find setting up and managing a distributed cluster
with `LXC` to be straightforward, compared with the alternative.

  To sum up, I believe `LXC` is an excellent tool for setting up
development and staging environment since it is much simpler to use
and much less resource-hungry when compared with alternatives.

## LXC ecosystem

Primarily speaking, installing `LXC` add two main executables to your
system :

- **LXD**: `LXD` is the 'brain' of the ecosystem. It is a `daemon` that
provides main containerization functionality, such as container runtime
and agent. It exposes an API to control behavior and interact with it,
such as launching a new container.
- **LXC**: `LXC` is nothing but a 'client' to `LXD`. Essentially, it provides
an easy-to-use interface to send requests to the `LXD` API and interact
with it. `LXC` is the software that end-users use most often.

  The biggest issue with `LXC` adoption is that `LXD` is only available on
Linux machines, since at its core, `LXD` uses some Linux libraries such
as `Libvirt` and needs access to some features unique to Linux Kernel.

  On the other hand, `LXC` is available on every platform, so as long as
you have `LXD` running on some remote Linux machine; you can use `LXC`
to interact with it and use it.

## workflow

### workflow overview

to use LXC/LXD, you must have an LXD server ready and LXC client utility
available to you in your host machine.

LXD server can be installed on a remote node if needed as it exposes an
API, much like Docker daemon, which enables users to interact with the
daemon.

Keep in mind that the LXC command-line interface is available for all
operating systems while LXD is only available on Linux

This guide focuses on LXD running on your local machine, so we are
assuming that :

- you are using Linux on your local machine
- You have the `Snap` store installed and properly configured
- after install and initialization of LXD, the general workflow for using

LXC containers can be summarized in the following bullet points:

- define a profile specific to your container group
- launch an image and apply the profile to it. make sure to use
[images](https://images.linuxcontainers.org) with the `/cloud`
prefix, as they
- are the images with cloud-init preinstalled. e.g `Debian/buster/cloud`
wait for cloud-init to finish provisioning of the node

> Most of These instructions were written with the assumption
> that you are using a bash shell on a *nix host OS.

### installation

  While it is most certainly possible to compile LXC from the source,
it can be pretty cumbersome. The official, most updated LXC release
is available only through [`Snap`](https://snapcraft.io/) package
manager. From my experience, `Debian` and `Ubuntu` derivative Linux
distributions offer the most frictionless experience with the `Snap`
package manager.

- after installing Snap, run the following in the terminal to install
[`LXC`](https://snapcraft.io/LXD) :
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/installation/snap.sh&src=../contrib/scripts/docs/lxd/installation/snap.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/installation/snap.sh -->
```bash
# -- contrib/scripts/docs/lxd/installation/snap.sh
sudo apt install -y snapd
sudo snap install core
sudo snap install lxd
sudo usermod -aG lxd "$USER"
newgrp lxd
```
<!-- AUTO-GENERATED-CONTENT:END -->
### initialization

  After installing, you must initialize `LXD`. There are many different
configuration options, although, in my opinion, the most important
one is the storage backend type used with the storage pool. A storage
pool is a part of your host's filesystem dedicated to the usage of LXC
containers.

  LXD supports different storage backends for storage pools, such as
`btrfs`, `zfs`, and `dir`. I prefer the `dir` type as it does
not need preallocation of storage on the host, which can cause problems
further down the road, namely resizing the storage pool when it reaches
its limit.

- initialize LXD with `dir` storage backend (recommended)
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/initialization/dir.sh&src=../contrib/scripts/docs/lxd/initialization/dir.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/initialization/dir.sh -->
```bash
# -- contrib/scripts/docs/lxd/initialization/dir.sh
sudo lxd init \
  --auto \
  --network-address="0.0.0.0" \
  --network-port="8443" \
  --trust-password="$(whoami)" \
  --storage-backend="dir"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- initialize LXD with `btrfs` storage backend and `60GB` of preallocated
storage
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/initialization/btrfs.sh&src=../contrib/scripts/docs/lxd/initialization/btrfs.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/initialization/btrfs.sh -->
```bash
# -- contrib/scripts/docs/lxd/initialization/btrfs.sh
lxd init \
  --auto \
  --network-address="0.0.0.0" \
  --network-port="8443" \
  --trust-password="$(whoami)" \
  --storage-backend="btrfs" \
  --storage-create-loop="60" \
  --storage-pool="default"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- ensure LXC containers have access to the internet by running the
following command
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/initialization/iptables.sh&src=../contrib/scripts/docs/lxd/initialization/iptables.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/initialization/iptables.sh -->
```bash
# -- contrib/scripts/docs/lxd/initialization/iptables.sh
sudo iptables -P FORWARD ACCEPT
```
<!-- AUTO-GENERATED-CONTENT:END -->
### LXD profile setup

  LXD has the concept of `profile`, which
enables operators to define constraints and physical features associated
with a set of containers. these include but are not limited to :

- Disk mounts
- Sockets
- Kernel-based features and privileges, and capabilities
- GPU passthrough
- a cloud-init profile used for provisioning.

  We need to make sure you have prepared your SSH keys. I generally like
to use two sets of keys with my LXD profiles:

- primary key at `~/.ssh/id_rsa.pub`.
- profile-specific key at `~/.ssh/${profile}_id_rsa.pub` .

- run this snippet to ensure keys are generated and ready to be used with
the `cloud-lab` profile :
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/lxd-profile-setup/ssh-keys.sh&src=../contrib/scripts/docs/lxd/lxd-profile-setup/ssh-keys.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/lxd-profile-setup/ssh-keys.sh -->
```bash
# -- contrib/scripts/docs/lxd/lxd-profile-setup/ssh-keys.sh
export profile="cloud-lab"
rm -f ~/.ssh/${profile}_id_rsa* ;
echo >&2 "*** generating a new set of ssh keys for '$profile' on host" ;
[ ! -r ~/.ssh/id_rsa ] && ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N "" ;
ssh-keygen -b 4096 -t rsa -f ~/.ssh/${profile}_id_rsa -q -N "" ;
```
<!-- AUTO-GENERATED-CONTENT:END -->
- take a look at the actual profile which we are about to add
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/lxd-profile-setup/render.sh&src=../contrib/scripts/docs/lxd/lxd-profile-setup/render.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/lxd-profile-setup/render.sh -->
```bash
# -- contrib/scripts/docs/lxd/lxd-profile-setup/render.sh
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
```
<!-- AUTO-GENERATED-CONTENT:END -->
Once you approve of the rendered profile, we can move onto the next
phase, which is the actual task of creating and configuring the profile.

- let us ensure `cloud-lab` profile is created
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/lxd-profile-setup/create.sh&src=../contrib/scripts/docs/lxd/lxd-profile-setup/create.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/lxd-profile-setup/create.sh -->
```bash
# -- contrib/scripts/docs/lxd/lxd-profile-setup/create.sh
export profile="cloud-lab"
! lxc profile show "${profile}" > /dev/null 2>&1 && lxc profile create "${profile}"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- let us apply the desired values to the `cloud-lab` profile
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/lxd-profile-setup/apply.sh&src=../contrib/scripts/docs/lxd/lxd-profile-setup/apply.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/lxd-profile-setup/apply.sh -->
```bash
# -- contrib/scripts/docs/lxd/lxd-profile-setup/apply.sh
export profile="cloud-lab"
cat << PROFILE | lxc profile edit "${profile}"
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
```
<!-- AUTO-GENERATED-CONTENT:END -->
### container creation

- launch a container called `cloud-lab` with cloud-lab profile
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/container-creation/launch.sh&src=../contrib/scripts/docs/lxd/container-creation/launch.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/container-creation/launch.sh -->
```bash
# -- contrib/scripts/docs/lxd/container-creation/launch.sh
export container_name="cloud-lab"
export profile="cloud-lab"
lxc launch \
  --profile="default" \
  --profile="${profile}" \
  images:debian/buster/cloud \
  "${container_name}"  \
```
<!-- AUTO-GENERATED-CONTENT:END -->
> you can launch a KVM instead of a container through
> the '--vm' flag: `lxc launch --vm ....`

- wait for `cloud-init` to finish the initial setup
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/container-creation/wait.sh&src=../contrib/scripts/docs/lxd/container-creation/wait.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/container-creation/wait.sh -->
```bash
# -- contrib/scripts/docs/lxd/container-creation/wait.sh
export container_name="cloud-lab"
lxc exec "${container_name}" -- cloud-init status --wait
```
<!-- AUTO-GENERATED-CONTENT:END -->
- bonus: Now that your container is ready, we can set up your host's
`~/.ssh/config` for easy ssh access to the container :

> you need `jq` for this step
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/container-creation/ssh-config.sh&src=../contrib/scripts/docs/lxd/container-creation/ssh-config.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/container-creation/ssh-config.sh -->
```bash
# -- contrib/scripts/docs/lxd/container-creation/ssh-config.sh
export container_name="cloud-lab"
if ! command -- jq -h >/dev/null 2>&1; then
  echo >&2 "*** please install jq before running this snippet".
  exit 1
fi
ip=$(lxc list --format json | jq -r ".[]
| select(
  (.name==\"${container_name}\")
  and (.status==\"Running\")
)
|.state.network.eth0.addresses
|.[]
|select(.family==\"inet\").address")
echo >&2 "*** '$container_name' IP detected : $ip. copying ssh key"
echo >&2 "*** removing Pexisting '$container_name' config from ~/.ssh/config"
sed -n -i "/${container_name}/,/UserKnownHostsFile/!{//!p}" ~/.ssh/config || true
echo >&2 "*** storing ssh config for '$container_name' in ~/.ssh/config"
cat << EOF | tee -a ~/.ssh/config > /dev/null
Host ${container_name}
  user $(whoami)
  HostName ${ip}
  RequestTTY yes
  IdentityFile ~/.ssh/${container_name}_id_rsa
  IdentitiesOnly yes
  StrictHostKeyChecking no
  CheckHostIP no
  MACs hmac-sha2-256
  UserKnownHostsFile /dev/null
EOF
```
<!-- AUTO-GENERATED-CONTENT:END -->
- test SSH connectivity with the following commands:
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/container-creation/test-ssh.sh&src=../contrib/scripts/docs/lxd/container-creation/test-ssh.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/container-creation/test-ssh.sh -->
```bash
# -- contrib/scripts/docs/lxd/container-creation/test-ssh.sh
export container_name="cloud-lab"
export LC_ALL=C ;
ssh ${container_name} 2>/dev/null -- echo '***** $(whoami)@$(hostname) is ready *****'
```
<!-- AUTO-GENERATED-CONTENT:END -->
## common commands

- expand information about the specific profile
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/common-commands/profile-information.sh&src=../contrib/scripts/docs/lxd/common-commands/profile-information.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/common-commands/profile-information.sh -->
```bash
# -- contrib/scripts/docs/lxd/common-commands/profile-information.sh
export profile="cloud-lab"
lxc profile show "${profile}"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- expand container-specific profile information
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/common-commands/container-information.sh&src=../contrib/scripts/docs/lxd/common-commands/container-information.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/common-commands/container-information.sh -->
```bash
# -- contrib/scripts/docs/lxd/common-commands/container-information.sh
export container_name="cloud-lab"
lxc config show --expanded "${container_name}"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- get root shell into a container
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/common-commands/root-shell.sh&src=../contrib/scripts/docs/lxd/common-commands/root-shell.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/common-commands/root-shell.sh -->
```bash
# -- contrib/scripts/docs/lxd/common-commands/root-shell.sh
export container_name="cloud-lab"
lxc exec "${container_name}" bash
```
<!-- AUTO-GENERATED-CONTENT:END -->
- list all containers
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/common-commands/list-containers.sh&src=../contrib/scripts/docs/lxd/common-commands/list-containers.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/common-commands/list-containers.sh -->
```bash
# -- contrib/scripts/docs/lxd/common-commands/list-containers.sh
lxc list
```
<!-- AUTO-GENERATED-CONTENT:END -->
- log in as a specific user
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/common-commands/login.sh&src=../contrib/scripts/docs/lxd/common-commands/login.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/common-commands/login.sh -->
```bash
# -- contrib/scripts/docs/lxd/common-commands/login.sh
export container_name="cloud-lab"
lxc console "${container_name}"
```
<!-- AUTO-GENERATED-CONTENT:END -->
- remove a container
<!-- AUTO-GENERATED-CONTENT:START (CODE:syntax=bash&header=# -- contrib/scripts/docs/lxd/common-commands/remove-container.sh&src=../contrib/scripts/docs/lxd/common-commands/remove-container.sh) -->
<!-- The below code snippet is automatically added from ../contrib/scripts/docs/lxd/common-commands/remove-container.sh -->
```bash
# -- contrib/scripts/docs/lxd/common-commands/remove-container.sh
export container_name="cloud-lab"
lxc delete -f "${container_name}"
```
<!-- AUTO-GENERATED-CONTENT:END -->
## further reading

- [run graphical application inside LXD with GPU passthrough](https://blog.simos.info/running-x11-software-in-lxd-containers)
- [docker inside alpine LXD container](https://wildwolf.name/how-to-run-docker-in-alpine-container-in-lxc-lxd/)

## references

- [Linux Containers Project Homepage](https://linuxcontainers.org/)
