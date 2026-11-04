# Practice 7 – Terraform

**Aim:** Learn the Terraform workflow: `init → fmt → validate → plan → apply → show/state → destroy`.

```bash
cd practices/07-terraform-basics
terraform init          # downloads aws + random providers
terraform fmt           # formats code
terraform validate      # syntax check
terraform plan          # preview
terraform apply -auto-approve
terraform state list    # resources tracked in state
terraform output
terraform destroy -auto-approve
```

**Concepts shown:** provider, variable, data source (`aws_vpc`), resource, output, state file, random provider.

**Screenshots to take:** plan output, apply output, SG in EC2 console → Security Groups, destroy output.
