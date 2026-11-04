#!/usr/bin/env bash
# Zero-downtime release: bash release.sh <dockerhub-user> <version>
# Builds + pushes image, then Terraform updates the launch template -> ASG rolling instance refresh
set -euo pipefail
USER=${1:?dockerhub user}; VER=${2:?version e.g. 1.1.0}
cd "$(dirname "$0")"
APP=../05-cloud-native-monitoring/app
(cd $APP && npm ci && npm test)                        # fail fast -> no broken deploys
docker build -t "$USER/pbl-shop:$VER" $APP
docker push "$USER/pbl-shop:$VER"
cd terraform
terraform apply -auto-approve -var "app_image=$USER/pbl-shop:$VER" -var "app_version=$VER"
ASG=$(terraform output -raw asg_name)
echo "Instance refresh started:"; aws autoscaling describe-instance-refreshes --auto-scaling-group-name "$ASG" \
  --query 'InstanceRefreshes[0].{Status:Status,Pct:PercentageComplete}' --output table
