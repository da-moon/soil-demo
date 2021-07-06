FROM alpine
USER root
# [NOTE] install base packages
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache > /dev/null 2>&1 && \
  apk add --no-cache curl wget jq git ncurses vim \
  sudo terraform vault libcap neofetch ansible openssl libssl1.1  openssl-dev \
  docker docker-bash-completion \
  docker-compose docker-compose-bash-completion \
  minikube kubectl kubectl-bash-completion helm \
  && \
  setcap cap_ipc_lock= /usr/sbin/vault && \
  vault --version && \
  terraform --version
RUN wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && \
  chmod +x /tmp/vsls-reqs && \
  sed -i 's/libssl1.0/libssl1.1/g' /tmp/vsls-reqs && \
  bash /tmp/vsls-reqs
SHELL ["ash", "-c"]
# make a user for code
WORKDIR /home/code
RUN getent group sudo > /dev/null || sudo addgroup sudo > /dev/null 2>&1
RUN getent group code > /dev/null || sudo addgroup code > /dev/null 2>&1
RUN getent passwd code > /dev/null || sudo adduser \
  -G sudo \
  -h "/home/code" \
  -s /bin/ash \
  -u 33333 \
  -D \
  "code" "code" && \
  echo "code:code" | chpasswd > /dev/null 2>&1 && \
  sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers && \
  echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  # custom Bash prompt
  { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '";} >> .bashrc && \
  chown "code:code" /home/code -R
RUN echo 'alias tf="terraform"' | tee -a ~/.bash_aliases && \
  echo 'alias tfi="terraform init"' | tee -a ~/.bash_aliases && \
  echo 'alias tfa="terraform apply -auto-approve"' | tee -a ~/.bash_aliases && \
  echo 'alias tfd="terraform destroy -auto-approve"' | tee -a ~/.bash_aliases && \
  echo '[ -r ~/.bash_aliases ] && . ~/.bash_aliases' | tee -a ~/.bashrc
