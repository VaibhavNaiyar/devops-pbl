# Windows setup (one-time, ~30 min)

## 1. Install tools (PowerShell **as Administrator**)
```powershell
wsl --install -d Ubuntu            # reboot after this
winget install -e --id Amazon.AWSCLI
winget install -e --id Hashicorp.Terraform
winget install -e --id Docker.DockerDesktop
winget install -e --id Kubernetes.kubectl
winget install -e --id Kubernetes.kind
winget install -e --id Git.Git
```
Docker Desktop → Settings → Resources → **WSL integration** → enable Ubuntu.

## 2. Inside WSL Ubuntu (Ansible + same tools on Linux side)
```bash
sudo apt update && sudo apt install -y ansible unzip curl jq
# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip && unzip -q awscliv2.zip && sudo ./aws/install
# kubectl + kind
curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl" && sudo install kubectl /usr/local/bin/
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64 && sudo install kind /usr/local/bin/
ansible-galaxy collection install community.general
```
**Recommended:** do everything inside WSL. Copy the project there:
```bash
cp -r /mnt/e/devops/devops-pbl/devops-pbl ~/devops-pbl && cd ~/devops-pbl
```
(SSH keys need Linux file permissions, which don't work on `/mnt/e`.)

## 3. AWS credentials (do NOT use the root account)
1. AWS Console → IAM → Users → **Create user** `devops-lab` → Attach policy `AdministratorAccess`.
2. User → Security credentials → **Create access key** → "Command Line Interface".
3. In WSL: `aws configure` → paste key, secret, region `us-east-1`, output `json`.
4. Test: `aws sts get-caller-identity`
5. Billing → Budgets → create a **$5 monthly budget** with email alert.

## 4. Accounts for VLE 7–9
- GitHub: create a repo, then `git init && git add . && git commit -m "PBL" && git remote add origin <url> && git push -u origin main`
- Docker Hub: create account + access token, then `docker login`.

## 5. Verify
```bash
aws --version; terraform -version; ansible --version; docker version; kubectl version --client; kind version
```
