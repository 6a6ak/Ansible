# Linux Infrastructure Automation with Ansible

A practical portfolio project for administering Rocky Linux/RHEL-compatible and Ubuntu/Debian hosts. It demonstrates a focused host baseline: packages, privileged access, safe SSH configuration, optional host firewalls, Docker Engine, and Prometheus Node Exporter.

## Architecture

~~~text
.
├── ansible.cfg
├── collections/requirements.yml
├── inventory/
│   ├── hosts.ini
│   └── group_vars/all/main.yml
├── playbooks/
│   ├── bootstrap.yml
│   ├── security.yml
│   ├── docker.yml
│   └── monitoring.yml
├── roles/
│   ├── common/
│   ├── users/
│   ├── ssh/
│   ├── firewall/
│   ├── docker/
│   └── node_exporter/
└── Bootstrap/genesis.sh
~~~

A single inventory and role set supports Debian and Red Hat OS families through gathered facts. Roles declare desired state, use defaults for customization, and use handlers only when services need reloading or restarting.

## Supported systems and prerequisites

Intended targets are Rocky Linux/RHEL-compatible systems and Ubuntu/Debian. The Node Exporter role supports x86_64 and aarch64. Docker uses Docker's upstream package repositories, so targets need outbound access and a supported OS release.

Install Ansible on the control node and required collections:

~~~bash
ansible-galaxy collection install -r collections/requirements.yml
~~~

Hosts need SSH, Python 3, and an account permitted to use sudo. Use an SSH agent or external private-key path; do not store private keys here.

## Inventory and configuration

Edit inventory/hosts.ini and place real hosts in the linux group. The checked-in addresses are documentation-only comments. Review inventory/group_vars/all/main.yml before a run.

| Variable | Purpose |
| --- | --- |
| admin_user | Administrative account to create |
| admin_user_ssh_public_keys | Public keys to authorize; defaults to an empty list |
| ssh_password_authentication | Disabled by default; deploy a verified key first |
| firewall_manage | Disabled by default to avoid unreviewed exposure changes |
| firewall_allowed_tcp_ports | TCP ports allowed when firewall management is enabled |
| docker_users | Existing accounts added to Docker's privileged group |
| node_exporter_listen_address | Exporter listener, default port 9100 |

Use an untracked Vault file for environment-specific secrets:

~~~bash
ansible-vault create inventory/group_vars/all/vault.yml
~~~

## Roles

- **common** updates package metadata, installs administration tools, enables Chrony, and applies a small sysctl baseline.
- **users** creates an administrative user, selects wheel or sudo for the OS, and deploys supplied public keys.
- **ssh** writes a drop-in configuration, validates it using sshd -t, and reloads only on change.
- **firewall** manages firewalld on RHEL-compatible systems or UFW on Debian. It permits configured TCP ports before enabling the firewall.
- **docker** installs Docker Engine from Docker's repository, enables its service, and optionally adds explicitly selected users to the Docker group.
- **node_exporter** downloads a selected upstream version, creates a system account, and manages a hardened systemd service.

Docker group membership is effectively root-equivalent. Keep docker_users small and intentional.

## Running it

First verify connectivity:

~~~bash
ansible linux -m ping
~~~

Run a component:

~~~bash
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/security.yml
ansible-playbook playbooks/docker.yml
ansible-playbook playbooks/monitoring.yml
~~~

Use tags for targeted work:

~~~bash
ansible-playbook playbooks/bootstrap.yml --tags ssh
ansible-playbook playbooks/security.yml --tags firewall -e firewall_manage=true
~~~

A local inventory stays ignored:

~~~bash
ansible-playbook -i inventory/hosts.local.ini playbooks/bootstrap.yml
~~~

## Validation

~~~bash
ansible-playbook --syntax-check playbooks/bootstrap.yml
ansible-playbook --syntax-check playbooks/security.yml
ansible-playbook --syntax-check playbooks/docker.yml
ansible-playbook --syntax-check playbooks/monitoring.yml
ansible-lint
~~~

Run the final command when Ansible Lint is installed; it is optional and not suppressed by repository configuration.

## Security, idempotency, and limitations

The ignore rules cover local inventories, Vault files, private keys, certificates, retry files, and common local state. Never commit passwords, tokens, real addresses, or private keys. Password authentication is disabled by default, so retain a tested key-based session before applying the SSH role. Firewall control is deliberately opt-in.

Native Ansible modules declare package, user, file, service, and firewall state, allowing repeat runs to converge without unnecessary changes. Node Exporter upgrades happen only when its explicit version variable changes.

This project manages host configuration only. It does not provision cloud resources, configure Prometheus scraping, manage Kubernetes, or replace a complete secrets-management system.

## Bootstrap helper

The corrected helper retains the original project idea while refusing to overwrite an existing directory:

~~~bash
./Bootstrap/genesis.sh /home/automation
~~~

For portfolio use, start with this repository rather than generating a new skeleton.
