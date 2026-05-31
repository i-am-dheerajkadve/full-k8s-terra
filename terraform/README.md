# Fixed Terraform EKS Project

This Terraform setup creates:

- VPC
- 2 public subnets
- 2 private subnets without NAT
- Internet Gateway
- ECR repository
- EKS cluster
- EKS managed node group in public subnets
- EKS add-ons
- CloudWatch cluster logs
- SNS email alert topic
- CloudWatch CPU alarm for worker node Auto Scaling Group

## Run

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

After apply:

```bash
aws eks update-kubeconfig --region ap-south-1 --name dheeraj-eks-cluster
kubectl get nodes
```

Confirm your SNS email subscription from your inbox.
