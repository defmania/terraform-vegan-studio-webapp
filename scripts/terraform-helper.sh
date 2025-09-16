#!/bin/bash

# Terraform Helper Script for Local Development
# This script helps run Terraform commands locally with proper variable handling

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars not found!"
    print_status "Please copy terraform.tfvars.example to terraform.tfvars and fill in your values:"
    print_status "cp terraform.tfvars.example terraform.tfvars"
    exit 1
fi

# Function to run terraform command with proper error handling
run_terraform() {
    local command=$1
    print_status "Running: terraform $command"
    
    if terraform $command; then
        print_status "✅ terraform $command completed successfully"
    else
        print_error "❌ terraform $command failed"
        exit 1
    fi
}

# Main script logic
case "${1:-}" in
    "init")
        print_status "Initializing Terraform..."
        run_terraform "init"
        ;;
    "plan")
        print_status "Creating Terraform plan..."
        run_terraform "init"
        run_terraform "plan"
        ;;
    "apply")
        print_warning "This will apply changes to your AWS infrastructure!"
        read -p "Are you sure? (yes/no): " -r
        if [[ $REPLY =~ ^yes$ ]]; then
            run_terraform "init"
            run_terraform "apply"
        else
            print_status "Apply cancelled by user"
        fi
        ;;
    "destroy")
        print_warning "This will DESTROY your AWS infrastructure!"
        print_warning "This action cannot be undone!"
        read -p "Are you absolutely sure? Type 'destroy' to confirm: " -r
        if [[ $REPLY == "destroy" ]]; then
            run_terraform "destroy"
        else
            print_status "Destroy cancelled by user"
        fi
        ;;
    "fmt")
        print_status "Formatting Terraform files..."
        terraform fmt -recursive
        print_status "✅ Terraform files formatted"
        ;;
    "validate")
        print_status "Validating Terraform configuration..."
        run_terraform "init"
        run_terraform "validate"
        ;;
    "check")
        print_status "Running all validation checks..."
        terraform fmt -check -recursive
        run_terraform "init"
        run_terraform "validate"
        run_terraform "plan"
        print_status "✅ All validation checks passed"
        ;;
    *)
        echo "Terraform Helper Script"
        echo ""
        echo "Usage: $0 {init|plan|apply|destroy|fmt|validate|check}"
        echo ""
        echo "Commands:"
        echo "  init     - Initialize Terraform working directory"
        echo "  plan     - Create and show an execution plan"
        echo "  apply    - Apply the Terraform configuration"
        echo "  destroy  - Destroy the Terraform-managed infrastructure"
        echo "  fmt      - Format Terraform files"
        echo "  validate - Validate the Terraform configuration"
        echo "  check    - Run all validation checks (fmt, validate, plan)"
        echo ""
        echo "Prerequisites:"
        echo "  - Copy terraform.tfvars.example to terraform.tfvars"
        echo "  - Fill in your AWS credentials and configuration"
        echo "  - Ensure you have proper AWS CLI access configured"
        exit 1
        ;;
esac