# VLE 6 – E-commerce company: frequent deployment failures, manual server setup, downtime during releases

## Problem → Solution
| Problem | Root cause | DevOps solution in this project |
|---|---|---|
| Manual server setup | Snowflake servers, SSH config by hand | **Terraform** (all infra as code) + **launch template user-data** installs Docker & app automatically |
| Frequent deployment failures | Untested code, environment drift | **Automated tests** gate the release (`npm test`), **immutable Docker images** with version tags |
| Downtime during releases | Stop-old-then-start-new on one server | **ALB + ASG rolling instance refresh** with `min_healthy_percentage = 100` (new instances pass health checks before old ones are drained) |
| Bad release stays live | No rollback | `auto_rollback = true` + previous image tag redeploy |
| Outages unnoticed | No monitoring | **ALB health checks** (self-healing), **CloudWatch alarms** (UnHealthyHostCount, 5xx), CPU target-tracking autoscaling |
| Security | Open SSH | No SSH at all — **SSM Session Manager** via IAM role; app SG only accepts traffic from ALB |

## Run
```bash
# 1. push v1.0.0 image
bash release.sh <dockerhub-user> 1.0.0          # first run creates everything (~4 min)
# 2. open the URL output, then in a 2nd terminal:
bash check-downtime.sh
# 3. release v1.1.0 while traffic is running
bash release.sh <dockerhub-user> 1.1.0          # watch versions switch with failures=0
# 4. cleanup (ALB costs ~$0.02/hr)
cd terraform && terraform destroy -auto-approve
```
**Screenshots:** ALB target group healthy targets, ASG Instance refresh tab, check-downtime output showing 1.0.0 → 1.1.0 with 0 failures, CloudWatch alarms.
