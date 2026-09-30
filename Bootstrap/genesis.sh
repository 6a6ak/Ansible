#!/usr/bin/env bash
set -euo pipefail

target_root="${1:-"$HOME"}"
project_directory="${target_root%/}/Ansible"

if [[ -e "$project_directory" ]]; then
  printf 'Refusing to overwrite existing project: %s\n' "$project_directory" >&2
  exit 1
fi

mkdir -p "$project_directory"/{inventory/group_vars/all,playbooks,roles}
printf '[defaults]\ninventory = inventory/hosts.ini\nroles_path = roles\n' > "$project_directory/ansible.cfg"
printf '[linux]\n# host-01 ansible_host=192.0.2.10 ansible_user=automation\n' > "$project_directory/inventory/hosts.ini"
printf '%s\n' 'Created a minimal Ansible skeleton. No credentials or keys were created.'
