# Deploy counter-app in the highly available auto-scaling group (ASG) with auto refresh from S3 bucket using Terraform and code update using CICD Pipeline

### Pre-requisite:
Verify below apps installed on your PC:

AWS Cli

Terraform

### Step 1: Update Key Pair and VPC ID
Logon to aws console

1. Create new access key pair for instances
   
   EC2 > Network & security > key pairs > create key pair
   
2. update the key pair name inside _vars.tf_ file from the folder ASG-ADv2 (line no. 42)
   
3. Goto VPC and Copy the default VPC id
   
   vpc > your vpcs
   
4. Update default VPC id inside _vars.tf_ file from the folder ASG-ADv2 (line no. 17)

### Step 2: Create S3 Bucket and ASG
Goto the folder ASG-ADv2 and Run below commands to create S3 and ASG with EC2 instance
```
	$ aws configure 
	$ terraform init
	$ terraform plan
	$ terraform apply
```
### Step 3: Create CICD
1. Create new repo in the GitLab
   
2. Goto the Settings and upate credentils / Keys and S3 bucket name to copy application files to S3
   
3. Upload application files from the _www_ folder to the newly created GitLab repo
   
4. Upload CICD pipeline configuration (.gitlab-ci.yaml) file from the _CICD_ folder  to the newly created GitLab repo
   
5. Run the pipeline if not triggered automatically

### Step 4: Test Application
1. Goto EC2 on the AWS comsole and copy public ip of the any EC2 instance and browse it in the internet browser. apache web page should be available or else goto ALB and copy dns name and browse it in the internet browser. apache web page should be available
   
2. Goto S3 bucket and verify application files are transfered from GitLab repo
   
4. Reboot EC2 instances so that cronjob in the instance should copy application files at startup from S3 bucket
   
5. Again browse instance public ip or ALB domain name, counter-app (Incremental and decremental Counter application) index  page should be available


### Step 5: Clean up
Goto folder ASG-AD and run below command to delate all resources

	$ terraform apply -destroy
