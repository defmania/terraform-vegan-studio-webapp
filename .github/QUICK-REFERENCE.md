# 🚀 Terraform CI/CD Quick Reference

## Workflow Overview

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `terraform-validate.yml` | All branches, .tf file changes | Basic validation and formatting checks |
| `terraform-security.yml` | main/develop branches, .tf file changes | Security scanning and cost estimation |
| `terraform-deploy.yml` | Push to main/develop, PRs, manual dispatch | Full deployment pipeline |

## Quick Actions

### 🔄 Deploy Infrastructure
```bash
# Via GitHub UI
1. Go to Actions → Terraform Deploy → Run workflow
2. Select branch: main
3. Choose action: apply

# Via Git
git push origin main  # Auto-deploys on main branch
```

### 📋 Plan Changes
```bash
# Create PR to see plan
git checkout -b feature/my-changes
git push origin feature/my-changes
# Create PR → Plan will be posted as comment

# Manual plan
Actions → Terraform Deploy → Run workflow → plan
```

### ⚠️ Destroy Infrastructure
```bash
# Manual only - via GitHub UI
Actions → Terraform Deploy → Run workflow → destroy
```

### 🔍 Validate Code
```bash
# Automatic on any .tf file change
git add . && git push

# Local validation
./scripts/terraform-helper.sh check
```

## Required Secrets

### AWS Authentication
```
AWS_ROLE_ARN (OIDC) or AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY
```

### Infrastructure Variables
```
DB_PASSWORD
APP_FQDN
HOSTED_ZONE_NAME
```

### Optional
```
S3_BUCKET_NAME
EC2_KEY_PAIR_NAME
INFRACOST_API_KEY
```

## Branch Strategy

- `main` → Production deployments (auto-apply)
- `develop` → Development environment (plan only)
- Feature branches → Validation only

## Emergency Procedures

### 🚨 Stop Deployment
1. Go to Actions tab
2. Find running workflow
3. Click "Cancel workflow"

### 🔒 Lock State
- Terraform state is automatically locked during operations
- DynamoDB table: `terraform-up-and-running-locks`

### 🔧 Manual Intervention
- Access AWS console for emergency fixes
- Use local Terraform with same backend configuration
- Always coordinate with team before manual changes

## Monitoring

- ✅ **GitHub Actions**: Real-time workflow status
- 🔒 **Security Tab**: Security scan results
- 💰 **PR Comments**: Cost impact analysis
- 📊 **Step Summary**: Deployment outcomes

## Support

- 📖 [Full Documentation](.github/DEPLOYMENT.md)
- 🛠️ [Local Helper Script](scripts/terraform-helper.sh)
- 🏗️ [Terraform Modules](modules/)