Example of a Terraform configuration that uses modules to provision an **EC2 instance with Jenkins** and a **networking setup** (VPC, subnet, and security groups). The example is broken into reusable modules and a main configuration file.

---

### **Directory Structure**  
```plaintext
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── ec2-jenkins/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── security-group/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
```

---

### **Main Configuration (`main.tf`)**
```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "thej"
}

# Networking Module
module "networking" {
  source            = "./modules/networking"
  cidr_block        = "10.10.10.0/24"
  public_subnet     = "10.10.10.0/26"
  availability_zone = "us-east-1a"
}



# Security Group Module
module "security_group" {
  source        = "./modules/security-group"
  vpc_id        = module.networking.vpc_id
  ingress_ports = [22, 8080] # SSH and Jenkins
}

# EC2 Jenkins Module
module "ec2_jenkins" {
  source            = "./modules/ec2-jenkins"
  instance_type     = "t2.micro"
  ami_id            = "ami-0c02fb55956c7d316" # Amazon Linux 2
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.security_group.security_group_id
  key_name          = "abc" # this key need to available in local machine (download before this tf excute from aws console )
}

```

---

### **Variables (`variables.tf`)**
```hcl
variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  default     = "my-key"
}
```

---

### **Outputs (`outputs.tf`)**
```hcl
output "ec2_public_ip" {
  value = module.ec2_jenkins.public_ip
}

output "vpc_id" {
  value = module.networking.vpc_id
}
```

---

### **Networking Module (`modules/networking/main.tf`)**
```hcl
# VPC Resource
resource "aws_vpc" "main-vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "test-vpc"
  }
}

# Subnet Resource
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.public_subnet
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

# Internet Gateway Resource
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "test-igw"
  }
}

# Route Table Resource (for public subnet)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Default route to the Internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}
```

**Networking Variables (`modules/networking/variables.tf`)**
```hcl
variable "cidr_block" {}
variable "public_subnet" {}
variable "availability_zone" {}
```

**Networking Outputs (`modules/networking/outputs.tf`)**
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}
```

---

### **Security Group Module (`modules/security-group/main.tf`)**
```hcl
resource "aws_security_group" "jenkins_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "security_group_id" {
  value = aws_security_group.jenkins_sg.id
}
```

**Security Group Variables (`modules/security-group/variables.tf`)**
```hcl
variable "vpc_id" {}
variable "ingress_ports" {
  default = []
}
```

**Security Group Outputs (`modules/security-group/outputs.tf`)**
```hcl
output "security_group_id" {
  value = aws_security_group.jenkins_sg.id
}
```

---

### **EC2 Jenkins Module (`modules/ec2-jenkins/main.tf`)**
```hcl
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "Jenkins-Server"
  }
}

output "public_ip" {
  value = aws_instance.jenkins.public_ip
}
```

**EC2 Jenkins Variables (`modules/ec2-jenkins/variables.tf`)**
```hcl
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
```

**EC2 Jenkins Outputs (`modules/ec2-jenkins/outputs.tf`)**
```hcl
output "public_ip" {
  value = aws_instance.jenkins.public_ip
}
```

---

### **Steps to Deploy**
1. **Initialize Terraform**:  
   ```bash
   terraform init
   ```

2. **Validate Configuration**:  
   ```bash
   terraform validate
   ```

3. **Apply Configuration**:  
   ```bash
   terraform apply
   ```

4. **Check Outputs**:  
   After applying, Terraform will output the public IP of the Jenkins EC2 instance and VPC ID.

---