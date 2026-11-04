# Practice 9 – Setting Up and Running an Ansible Playbook  (run inside WSL Ubuntu)

```bash
sudo apt update && sudo apt install -y ansible
cd practices/09-ansible-playbook
ansible --version
ansible all -m ping                       # ad-hoc command
ansible-playbook playbook.yml --syntax-check
ansible-playbook playbook.yml --check     # dry run
ansible-playbook playbook.yml -K          # real run (asks sudo password)
ansible-playbook playbook.yml -K          # run again -> "changed=0" shows idempotency
```
Concepts: inventory, ansible.cfg, ad-hoc vs playbook, modules (apt/user/file/copy/debug), variables, facts, `become`, idempotency.
