# s3_bucket_static_website
### This repository contains the necessary Terraform configuration files to host a static website on an S3 bucket.

# Prerequisites: 
1. AWS Account: 
- You need access to an AWS account to create and configure the necessary resources.
2. IAM Role: 
- Make sure you have an IAM role with the necessary permissions to create and manage S3 buckets, IAM roles with terraform instance.
3. Register a Domain: 
- Ensure that you have a registered domain name through a domain registrar. 
4. Get an SSL certificate for your custom domain.
5. Configure CloudFront distribution configuration

# Setup Instructions
### Follow the steps below to set up and deploy your static website on the Demo S3 bucket using Terraform:

1. Clone the repository:
- git clone https://github.com/oksanaivashko/s3_bucket_static_website.git
2. Update the necessary values in the Terraform variables file (variables.tf) to match your preferences and requirements.