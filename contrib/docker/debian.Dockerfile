FROM debian:buster
ENV TERM=xterm
SHELL ["/bin/bash", "-c"]
ENV HASHICORP_BASE_URL="https://releases.hashicorp.com"

RUN export DEBIAN_FRONTEND=noninteractive; \
  apt-get update && \
  apt-get install -yqq apt-utils pkg-config && \
  apt-get install -yqq curl wget neofetch jq git libncurses5-dev unzip libncursesw5-dev vim locales openssl ca-certificates gnupg2 && \
  locale-gen en_US.UTF-8

RUN wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && \
  chmod +x /tmp/vsls-reqs && \
  bash /tmp/vsls-reqs
RUN curl -sL "$HASHICORP_BASE_URL/consul/index.json" | \
  jq -r '.versions[].version' | \
  sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
  grep -E -v 'ent|rc|beta' | \
  tail -1 | \
  xargs -I {} \
  wget -q -O /usr/local/bin/consul.zip "$HASHICORP_BASE_URL/consul/{}/consul_{}_linux_amd64.zip" && \
  unzip -q -d /usr/local/bin /usr/local/bin/consul.zip && \
  rm /usr/local/bin/consul.zip && \
  consul --version
RUN curl -sL "$HASHICORP_BASE_URL/vault/index.json" | \
  jq -r '.versions[].version' | \
  sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
  grep -E -v 'ent|rc|beta' | \
  tail -1 | \
  xargs -I {} \
  wget -q -O /usr/local/bin/vault.zip "$HASHICORP_BASE_URL/vault/{}/vault_{}_linux_amd64.zip" && \
  unzip -q -d /usr/local/bin /usr/local/bin/vault.zip && \
  rm /usr/local/bin/vault.zip && \
  vault --version
RUN curl -sL "$HASHICORP_BASE_URL/terraform/index.json" | \
  jq -r '.versions[].version' | \
  sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
  grep -E -v 'ent|rc|beta' | \
  tail -1 | \
  xargs -I {} \
  wget -q -O /usr/local/bin/terraform.zip "$HASHICORP_BASE_URL/terraform/{}/terraform_{}_linux_amd64.zip" && \
  unzip -q -d /usr/local/bin /usr/local/bin/terraform.zip && \
  rm /usr/local/bin/terraform.zip && \
  terraform --version
RUN export DEBIAN_FRONTEND=noninteractive; \
  apt-get install -yqq sudo && \
  useradd \
  --no-log-init \
  --uid 1000 \
  --create-home \
  --groups sudo \
  --shell /bin/bash \
  --password `perl -e "print crypt('code','sa');"` \
  code && \
  echo root:code | chpasswd && \
  sed \
  -i.bak \
  -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
  /etc/sudoers && \
  { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '";} >> .bashrc && \
  chown "code:code" /home/code -R
RUN export DEBIAN_FRONTEND=noninteractive; \
  apt-get autoclean -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /home/code
USER code
RUN echo 'alias tf="terraform"' | tee -a ~/.bash_aliases && \
  echo 'alias tfi="terraform init"' | tee -a ~/.bash_aliases && \
  echo 'alias tfa="terraform apply -auto-approve"' | tee -a ~/.bash_aliases && \
  echo 'alias tfd="terraform destroy -auto-approve"' | tee -a ~/.bash_aliases && \
  echo '[ -r ~/.bash_aliases ] && . ~/.bash_aliases' | tee -a ~/.bashrc
COPY --from=fjolsvin/just:latest /workspace /usr/local/bin
COPY --from=fjolsvin/convco:latest /workspace /usr/local/bin
COPY --from=fjolsvin/clog:latest /workspace /usr/local/bin
COPY --from=fjolsvin/exa:latest /workspace /usr/local/bin
COPY --from=fjolsvin/bat:latest /workspace /usr/local/bin
COPY --from=fjolsvin/tokei:latest /workspace /usr/local/bin
