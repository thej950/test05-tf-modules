# Global variables values passing before giveing values here define variables state in variable.tf file 
vpc_name          = "thej-vpc"
availability_zone = ["us-east-1a", "us-east-1b"]
cidr_block        = "10.10.10.0/24"
public_subnet     = "10.10.10.0/26"
private_subnet    = "10.10.10.64/26"