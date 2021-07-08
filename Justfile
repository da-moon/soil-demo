# !/usr/bin/env -S just --justfile
# vi: ft=just tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
default:
  @just --choose

alias vim-dep := spacevim-dependencies
spacevim-dependencies:
  #!/usr/bin/env bash
  set -euo pipefail
  sudo yarn global add --prefix /usr/local \
    remark \
    remark-cli \
    remark-stringify \
    remark-frontmatter \
    wcwidth \
    prettier \
    bash-language-server \
    dockerfile-language-server-nodejs ;

docker-socket-chown:
  #!/usr/bin/env bash
  set -euo pipefail
  sudo chown "$(id -u gitpod):$(cut -d: -f3 < <(getent group docker))" /var/run/docker.sock

alias fo := fix-ownership
fix-ownership: docker-socket-chown
  #!/usr/bin/env bash
  set -euo pipefail
  sudo find "${HOME}/" "/workspace" -not -group `id -g` -not -user `id -u` -print0 | xargs -P 0 -0 --no-run-if-empty sudo chown --no-dereference "`id -u`:`id -g`" || true ;
  # sudo find "/workspace" -not -group `id -g` -not -user `id -u` -print | xargs -I {}  -P `nproc` --no-run-if-empty sudo chown --no-dereference "`id -u`:`id -g`" {} || true ;

docker-login-env:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "*** ensuring current user belongs to docker group" ;
  sudo usermod -aG docker "$(whoami)"
  echo "*** ensuring required environment variables are present" ;
  while [ -z "$DOCKER_USERNAME" ] ; do \
  printf "\n❗ The DOCKER_USERNAME environment variable is required. Please enter its value.\n" ;
  read -s -p "DOCKER_USERNAME: " DOCKER_USERNAME ; \
  done ; gp env DOCKER_USERNAME=$DOCKER_USERNAME && printf "\nThanks\n" || true ;
  while [ -z "$DOCKER_PASSWORD" ] ; do \
  printf "\n❗ The DOCKER_PASSWORD environment variable is required. Please enter its value.\n" ;
  read -s -p "DOCKER_PASSWORD: " DOCKER_PASSWORD ; \
  done ; gp env DOCKER_PASSWORD=$DOCKER_PASSWORD && printf "\nThanks\n" || true ;

alias dl := docker-login
docker-login: fix-ownership docker-login-env
  #!/usr/bin/env bash
  set -euo pipefail
  echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin ;
  just fix-ownership

alias gp := gitpod
gitpod:
  #!/usr/bin/env bash
  set -euxo pipefail
  bash "{{ justfile_directory() }}/.gp/build.sh"
ssh-pub-key-env:
  #!/usr/bin/env bash
  set -euo pipefail
  while [ -z "$SSH_PUB_KEY" ] ; do \
  printf "\n❗ The SSH_PUB_KEY environment variable is required. Please enter its value.\n" ;
  read -s -p "SSH_PUB_KEY: " SSH_PUB_KEY ; \
  done ; gp env SSH_PUB_KEY=$SSH_PUB_KEY && printf "\nThanks\n" || true ;

ssh-pub-key: fix-ownership ssh-pub-key-env
  #!/usr/bin/env bash
  set -euo pipefail
  mkdir -p ${HOME}/.ssh ;
  echo "${SSH_PUB_KEY}" | tee ${HOME}/.ssh/authorized_keys > /dev/null ;
  chmod 700 ${HOME}/.ssh ;
  chmod 600 ${HOME}/.ssh/authorized_keys ;
  just fix-ownership
  exit 0

chisel: fix-ownership
  #!/usr/bin/env bash
  set -euo pipefail
  [ -f ${HOME}/chisel.pid ] && echo "*** killing chisel server" && kill -9 "$(cat ${HOME}/chisel.pid)" && rm -rf ${HOME}/chisel.pid ;
  pushd ${HOME}/ ;
  echo "*** starting chisel server" ;
  bash -c "chisel server --socks5 --pid > ${HOME}/chisel.log 2>&1 &" ;
  echo "*** chisel was started successfully" ;
  popd ;
  just fix-ownership
  exit 0

dropbear: fix-ownership
  #!/usr/bin/env bash
  set -euo pipefail
  [ ! -f ${HOME}/dropbear.hostkey ] && echo "*** generating dropbear host key" && dropbearkey -t rsa -f ${HOME}/dropbear.hostkey ;
  [ -f ${HOME}/dropbear.pid ] && echo "*** killing dropbear server" && kill -9 "$(cat ${HOME}/dropbear.pid)" && rm -rf ${HOME}/dropbear.pid ;
  echo "*** starting dropbear server" ;
  bash -c "dropbear -r ${HOME}/dropbear.hostkey -F -E -s -p 2222 -P ${HOME}/dropbear.pid > ${HOME}/dropbear.log 2>&1 &" ;
  echo "*** dropbear server was started successfully" ;
  just fix-ownership
  exit 0
alias ssh := ssh-config
ssh-config: ssh-pub-key
  #!/usr/bin/env bash
  set -euo pipefail
  cat << EOF
  Host $(gp url | sed -e 's/https:\/\///g' -e 's/[.].*$//g')
    HostName localhost
    User gitpod
    Port 2222
    ProxyCommand chisel client $(gp url 8080) stdio:%h:%p
    RemoteCommand cd /workspace && exec bash --login
    RequestTTY yes
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
    StrictHostKeyChecking no
    CheckHostIP no
    MACs hmac-sha2-256
    UserKnownHostsFile /dev/null
  EOF
alias gcloud := vagrant-gcloud-up
alias vgu := vagrant-gcloud-up
vagrant-gcloud-up:
  #!/usr/bin/env bash
  set -xeuo pipefail
  export NAME="$(basename "{{justfile_directory()}}")" ;
  plugins=(
    "vagrant-share"
    "vagrant-google"
    "vagrant-rsync-back"
  );
  available_plugins=($(vagrant plugin list | awk '{print $1}'))
  intersection=($(comm -12 <(for X in "${plugins[@]}"; do echo "${X}"; done|sort)  <(for X in "${available_plugins[@]}"; do echo "${X}"; done|sort)))
  to_install=($(echo ${intersection[*]} ${plugins[*]} | sed 's/ /\n/g' | sort -n | uniq -u | paste -sd " " - ))
  if [ ${#to_install[@]} -ne 0  ];then
    vagrant plugin install ${to_install[@]}
  fi
  export GCLOUD_MACHINE_TYPE="n1-standard-2" ;
  export GCLOUD_DISK_SIZE="10";
  if [ -z ${GOOGLE_PROJECT_ID+x} ] || [ -z ${GOOGLE_PROJECT_ID} ]; then
    export GOOGLE_PROJECT_ID="$(gcloud config get-value core/project)" ;
  fi
  if [ -z ${GOOGLE_APPLICATION_CREDENTIALS+x} ] || [ -z ${GOOGLE_APPLICATION_CREDENTIALS} ]; then
    export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/${NAME}_gcloud.json" ;
  fi
  GCLOUD_IAM_ACCOUNT="${NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com"
  if ! gcloud iam service-accounts describe "${GCLOUD_IAM_ACCOUNT}" > /dev/null 2>&1; then
    gcloud iam service-accounts create "${NAME}" ;
    gcloud projects add-iam-policy-binding "${GOOGLE_PROJECT_ID}" \
      --member="serviceAccount:${GCLOUD_IAM_ACCOUNT}" \
      --role="roles/owner" ;
  fi
  if [ -r "${GOOGLE_APPLICATION_CREDENTIALS}" ];then
    rm ${GOOGLE_APPLICATION_CREDENTIALS}
  fi
  gcloud iam service-accounts keys list \
    --iam-account="${GCLOUD_IAM_ACCOUNT}" \
    --format="value(KEY_ID)" | xargs -I {} \
    gcloud iam service-accounts keys delete \
    --iam-account="${GCLOUD_IAM_ACCOUNT}" {} >/dev/null 2>&1 || true ;
  gcloud iam service-accounts keys \
    create ${GOOGLE_APPLICATION_CREDENTIALS} \
    --iam-account="${GCLOUD_IAM_ACCOUNT}" ;
  rm -f "~/.ssh/${NAME}" ;
  rm -f "~/.ssh/${NAME}.pub" ;
  ssh-keygen -q -N "" -t rsa -b 2048 -f "$HOME/.ssh/${NAME}" >/dev/null 2>&1 ;
  vagrant up --debug --provider=google

alias gcloud-down := vagrant-gcloud-teardown
alias vagrant-gcloud-delete := vagrant-gcloud-teardown
alias gcloud-delete := vagrant-gcloud-teardown
alias vgt := vagrant-gcloud-teardown
vagrant-gcloud-teardown:
  set -euo pipefail
  #!/usr/bin/env bash
  vagrant destroy -f || true ;
  export NAME="$(basename "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")" ;
  if [ -z ${GOOGLE_PROJECT_ID+x} ] || [ -z ${GOOGLE_PROJECT_ID} ]; then
  export GOOGLE_PROJECT_ID="$(gcloud config get-value core/project)" ;
  fi
  if [ -z ${GOOGLE_APPLICATION_CREDENTIALS+x} ] || [ -z ${GOOGLE_APPLICATION_CREDENTIALS} ]; then
  export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/${NAME}_gcloud.json" ;
  fi
  GCLOUD_IAM_ACCOUNT="${NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com"
  gcloud iam service-accounts delete --quiet "${GCLOUD_IAM_ACCOUNT}" || true ;
  rm -f "${GOOGLE_APPLICATION_CREDENTIALS}" ;
  rm -f "~/.ssh/${NAME}" ;
  rm -f "~/.ssh/${NAME}.pub" ;

# if [ -z ${GOOGLE_PROJECT_ID+x} ] || [ -z ${GOOGLE_PROJECT_ID} ]; then
# export GOOGLE_PROJECT_ID="$(gcloud config get-value core/project)" ;
# fi
# if [ -z ${GOOGLE_APPLICATION_CREDENTIALS+x} ] || [ -z ${GOOGLE_APPLICATION_CREDENTIALS} ]; then
# export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/${NAME}_gcloud.json" ;
# fi
# if [ -r "${GOOGLE_APPLICATION_CREDENTIALS}" ];then
# rm ${GOOGLE_APPLICATION_CREDENTIALS}
# gcloud iam service-accounts delete --quiet "${NAME}@${GOOGLE_PROJECT_IDiam.gserviceaccount.com" || true ;
# fi
# gcloud iam service-accounts create "${NAME}" ;
# gcloud projects add-iam-policy-binding "${GOOGLE_PROJECT_ID}" \
# --member="serviceAccount:${NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com" \
# --role="roles/owner" ;
# gcloud iam service-accounts keys \
# create ${GOOGLE_APPLICATION_CREDENTIALS} \
# --iam-account="${NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com" ;
# export GCLOUD_MACHINE_TYPE="n1-standard-8" ;
# export GCLOUD_DISK_SIZE="50GB";
# export GCLOUD_IMAGE="$(gcloud compute images list  --format='value(NAME)" --filter="name ~ debian AND family ~ debian-10')"
# export GCLOUD_IMAGE_PROJECT_ID=$(gcloud compute images list  --format='value(PROJECT)" --filter="name ~ debian AND family ~ debian-10')
# vagrant up

# available_plugins=$(vagrant plugin list)
# vagrant plugin list | grep -qF "${plugin}" || vagrant plugin install "${plugin}";