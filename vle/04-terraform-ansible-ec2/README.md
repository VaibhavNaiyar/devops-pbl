# VLE 4 – Deploy and configure an EC2 instance using Terraform and Ansible

**Flow:** Terraform creates key pair, security group (SSH from your IP only, HTTP), Ubuntu 24.04 t3.micro (encrypted gp3, IMDSv2) → writes `ansible/inventory.ini` automatically → Ansible installs nginx, ufw, fail2ban, deploys templated site.

```bash
# WSL Ubuntu, from this folder
bash run.sh        # ~3-4 min
bash destroy.sh    # ALWAYS run after screenshots
```
> Keep the project on the WSL filesystem (`~/devops-pbl`), not `/mnt/c`, otherwise the .pem permissions can't be set and SSH refuses the key.

**Screenshots:** terraform apply output, EC2 console instance, ansible PLAY RECAP, website in browser, destroy.
