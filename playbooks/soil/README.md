# soil

## Snippets

- Setup base dependencies for all inventory hosts

```bash
ansible-playbook \
  -i staging \
  --tags 01-install-prerequisites \
  site.yml
```

- install docker and docker-compose

```bash
ansible-playbook \
  -i staging \
  --limit staging \
  --tags 02-install-docker \
  site.yml
```

- build Soil from source and install it on all hosts

```bash
ansible-playbook \
  -v \
  -i staging \
  --limit staging \
  --tags 03-install-soil \
  site.yml
```

- configure soil

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 04-configure-soil \
  site.yml
```
