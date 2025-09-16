# 🚀 GitHub Actions CI/CD Pipeline for Terraform Infrastructure

This repository includes automated GitHub Actions workflows for deploying and managing the Vegan Studio Terraform infrastructure.

## 📋 Prerequisites

### Required GitHub Repository Secrets

The following secrets must be configured in your GitHub repository settings (`Settings` > `Secrets and variables` > `Actions`):

#### AWS Authentication (Choose One Method):

**Method 1: OIDC (Recommended)**
```
AWS_ROLE_ARN: arn:aws:iam::ACCOUNT_ID:role/github-actions-terraform-role
```

**Method 2: Access Keys (Fallback)**
```
AWS_ACCESS_KEY_ID: your-aws-access-key-id
AWS_SECRET_ACCESS_KEY: your-aws-secret-access-key
```

#### Required Infrastructure Variables:
```
DB_PASSWORD: your-secure-database-password
APP_FQDN: your-app-domain.com (e.g., veganstudio.example.com)
HOSTED_ZONE_NAME: example.com (your Route 53 hosted zone)
```

#### Optional Variables (with defaults):
```
S3_BUCKET_NAME: custom-bucket-name (default: vs-bucket-defmania)
EC2_KEY_PAIR_NAME: your-key-pair (default: def-yoga2)
```

#### Optional Security/Cost Tools:
```
INFRACOST_API_KEY: your-infracost-api-key (for cost estimation)
```

### AWS IAM Setup

#### Option 1: OIDC Identity Provider (Recommended)

1. Create an OIDC Identity Provider in AWS IAM:
   ```
   Provider URL: https://token.actions.githubusercontent.com
   Audience: sts.amazonaws.com
   ```

2. Create an IAM role with the following trust policy:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringEquals": {
             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
           },
           "StringLike": {
             "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/terraform-vegan-studio-webapp:*"
           }
         }
       }
     ]
   }
   ```

3. Attach the following AWS managed policies to the role:
   - `PowerUserAccess` (or create a custom policy with required permissions)

#### Option 2: IAM User with Access Keys

Create an IAM user with the necessary permissions and generate access keys.

## 🔄 Workflow Overview

### 1. Terraform Deploy (`terraform-deploy.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch

**Features:**
- **Format Check**: Validates Terraform code formatting
- **Initialize**: Sets up Terraform working directory
- **Validate**: Validates Terraform configuration
- **Plan**: Creates execution plan (always runs on PRs)
- **Apply**: Deploys infrastructure (only on main branch)
- **Destroy**: Destroys infrastructure (manual trigger only)
- **PR Comments**: Automatically posts plan results to pull requests
- **Concurrency Control**: Prevents conflicting runs
- **Environment Protection**: Uses GitHub environments for additional security

### 2. Security & Validation (`terraform-security.yml`)

**Triggers:**
- Changes to `.tf` files or workflow files

**Features:**
- **Checkov**: Security and compliance scanning
- **TFLint**: Terraform linting and validation
- **tfsec**: Security scanning with SARIF output
- **Cost Estimation**: Infracost integration for cost analysis on PRs
- **SARIF Upload**: Security findings visible in GitHub Security tab

## 🚦 Usage

### Deploying Infrastructure

1. **Development/Testing**: Create a pull request
   - Workflow runs plan and security checks
   - Results are posted as PR comments
   - Review the plan before merging

2. **Production Deployment**: Merge to `main` branch
   - Workflow automatically applies changes
   - Infrastructure is deployed to AWS

### Manual Operations

Use workflow dispatch for manual operations:

1. Go to `Actions` tab in your GitHub repository
2. Select `Terraform Deploy` workflow
3. Click `Run workflow`
4. Choose action: `plan`, `apply`, or `destroy`

### Monitoring Deployments

- **GitHub Actions**: View detailed logs in the Actions tab
- **Security Findings**: Check the Security tab for scanning results
- **Cost Estimates**: Review cost impacts in PR comments
- **Step Summary**: View deployment summaries after completion

## 🔒 Security Best Practices

1. **Secrets Management**: Store sensitive values as GitHub secrets
2. **Branch Protection**: Enable branch protection rules for `main`
3. **Environment Protection**: Configure environment protection rules
4. **OIDC Authentication**: Use OIDC instead of long-term access keys
5. **Least Privilege**: Grant minimal necessary permissions
6. **Security Scanning**: Review security findings before merging

## 🛠️ Customization

### Environment-Specific Configuration

The workflow supports different environments:
- **Development**: Triggered by `develop` branch
- **Production**: Triggered by `main` branch

### Adding New Variables

1. Add the variable to `variables.tf`
2. Update the workflow files to pass the variable
3. Add the secret to GitHub repository settings (if sensitive)

### Workflow Modifications

- **Terraform Version**: Update `TF_VERSION` in workflow files
- **AWS Region**: Update `AWS_REGION` environment variable
- **Approval Gates**: Configure GitHub environments for manual approvals

## 🔧 Troubleshooting

### Common Issues

1. **State Lock Errors**: 
   - Wait for current operations to complete
   - Check DynamoDB table for stuck locks

2. **Permission Errors**:
   - Verify AWS credentials and permissions
   - Check IAM role trust relationships

3. **Validation Failures**:
   - Review Terraform code for syntax errors
   - Check required variables are provided

4. **Backend Issues**:
   - Ensure S3 bucket and DynamoDB table exist
   - Verify backend configuration in `terraform.tf`

### Getting Help

- Check workflow logs in GitHub Actions
- Review Terraform documentation
- Validate AWS resource quotas and limits

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS IAM OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Infracost Documentation](https://www.infracost.io/docs/)