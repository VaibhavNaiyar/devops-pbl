#!/usr/bin/env bash
# One command: provision + configure. Run in WSL Ubuntu.
set -euo pipefail
cd "$(dirname "$0")"
ansible-galaxy collection install community.general >/dev/null
(cd terraform && terraform init -input=false && terraform apply -auto-approve -var "ssh_cidr=$(curl -4 -s ifconfig.me)/32")
chmod 400 pbl-vle4-key.pem
(cd ansible && ansible-playbook site.yml)
echo; echo "Open: $(cd terraform && terraform output -raw website)"
