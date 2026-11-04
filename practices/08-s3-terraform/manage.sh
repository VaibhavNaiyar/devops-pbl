#!/usr/bin/env bash
# Practice 8 - manage the Terraform-created bucket with Linux + AWS CLI commands
set -euo pipefail
BUCKET=$(terraform output -raw bucket_name)
echo "Bucket: $BUCKET"

mkdir -p demo-files
echo "Hello from PBL-2 at $(date)" > demo-files/hello.txt
cp /etc/hostname demo-files/host.txt 2>/dev/null || hostname > demo-files/host.txt
ls -lh demo-files

aws s3 cp demo-files/hello.txt "s3://$BUCKET/"            # upload single file
aws s3 sync demo-files "s3://$BUCKET/backup/"              # sync folder
aws s3 ls "s3://$BUCKET" --recursive --human-readable      # list

echo "v2 $(date)" > demo-files/hello.txt                    # new version
aws s3 cp demo-files/hello.txt "s3://$BUCKET/"
aws s3api list-object-versions --bucket "$BUCKET" --prefix hello.txt \
  --query 'Versions[].{Key:Key,Id:VersionId,Latest:IsLatest}' --output table

aws s3 cp "s3://$BUCKET/hello.txt" downloaded.txt && cat downloaded.txt
aws s3 presign "s3://$BUCKET/hello.txt" --expires-in 300   # temporary share link
aws s3 rm "s3://$BUCKET/backup/host.txt"
du -sh demo-files; wc -l demo-files/*
