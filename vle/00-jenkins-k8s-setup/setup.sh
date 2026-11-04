#!/usr/bin/env bash
# Creates kind cluster + Jenkins (+ SonarQube) and writes the kubeconfig Jenkins needs.
set -euo pipefail
cd "$(dirname "$0")"
kind get clusters | grep -q '^pbl$' || kind create cluster --config kind-config.yaml
kind get kubeconfig --name pbl --internal > kubeconfig-jenkins.yaml   # uses pbl-control-plane:6443 inside docker network
docker compose --profile devsecops up -d --build
echo "Waiting for Jenkins..."; sleep 30
echo "Initial admin password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
cat <<MSG

Next (in browser http://localhost:8080):
 1. Paste password -> Install suggested plugins -> create admin user
 2. Manage Jenkins -> Credentials -> System -> Global -> Add:
    - Kind "Username with password", ID: dockerhub-creds  (Docker Hub user + access token)
    - Kind "Secret file",            ID: kubeconfig       (upload $(pwd)/kubeconfig-jenkins.yaml)
    - (VLE 9) Kind "Secret text",    ID: sonar-token      (from SonarQube http://localhost:9000 -> My Account -> Security)
 3. New Item -> Pipeline -> "Pipeline script from SCM" -> Git -> your repo URL
    Script Path: vle/07-cicd-jenkins-k8s/Jenkinsfile   (or 08 / 09)
MSG
