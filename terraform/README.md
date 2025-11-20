# Spark Cluster Infrastructure - Terraform

This directory contains Terraform configurations to provision the infrastructure for a Spark cluster on Google Cloud Platform.

## Quick Start

1. **Update `terraform.tfvars`** with your GCP project details
2. **Place GCP credentials** at `./gcp-credentials.json` (or update path in `variables.tf`)
3. **Validate prerequisites** (optional but recommended):
   ```bash
   ./validate-terraform.sh
   ```
   This checks that Terraform is installed, initialized, credentials exist, and required variables are set.
4. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Outputs

After applying, use outputs to get IP addresses:

```bash
terraform output master_external_ip
terraform output master_internal_ip
terraform output worker_external_ips
terraform output edge_external_ip
```

Or generate Ansible inventory automatically:
```bash
cd ../spark-ansible
./generate-inventory.sh
```

## Variables

See `variables.tf` for all available variables. Key variables in `terraform.tfvars`:
- `project_id`: Your GCP project ID
- `service_account_email`: Service account for VMs
- `worker_count`: Number of worker nodes (default: 3)

## Modules

- **network**: Creates VPC, subnet, and firewall rules
- **compute**: Creates VM instances (master, workers, edge)

## Cleanup

```bash
terraform destroy
```

