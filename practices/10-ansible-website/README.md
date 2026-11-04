# Practice 10 – Deploying a website using Ansible

Needs an Ubuntu EC2 with port 22 + 80 open. Easiest: run `vle/04-terraform-ansible-ec2/terraform` first and copy the IP, or launch one manually.

```bash
# in WSL
cp /mnt/c/path/to/pbl-key.pem ~/.ssh/ && chmod 400 ~/.ssh/pbl-key.pem
# edit inventory.ini -> put EC2 IP
ansible web -m ping
ansible-playbook deploy-website.yml
# open http://EC2_IP in browser
```
Concepts: templates (Jinja2 + facts), handlers, service module, uri module for verification.
