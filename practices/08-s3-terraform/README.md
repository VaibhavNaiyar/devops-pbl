# Practice 8 – Deploy an S3 bucket using Terraform and manage it with Linux commands

```bash
cd practices/08-s3-terraform
terraform init && terraform apply -auto-approve
bash manage.sh            # run in WSL/Git Bash
terraform destroy -auto-approve
```
Bucket gets: versioning, AES256 encryption, public-access block, 30-day lifecycle for old versions.
`manage.sh` uses `ls, cp, mkdir, echo, cat, du, wc` + `aws s3 cp/sync/ls/rm/presign` and `s3api list-object-versions`.
