#### **1. Variables**

##### **String Variable**
```hcl
variable "environment" {
  type        = string
  default     = "development"
  description = "The environment for deployment"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-app-${var.environment}"
}
```
- Creates an S3 bucket with a name based on the environment (e.g., `my-app-development`).

---

##### **Number Variable**
```hcl
variable "instance_count" {
  type        = number
  default     = 2
  description = "Number of instances to create"
}

resource "aws_instance" "example" {
  count = var.instance_count
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```
- Creates the specified number of EC2 instances.

---

##### **Boolean Variable**
```hcl
variable "enable_logging" {
  type        = bool
  default     = true
}

resource "aws_s3_bucket" "logging" {
  count = var.enable_logging ? 1 : 0
  bucket = "logging-bucket"
}
```
- Creates the logging bucket only if logging is enabled.

---

##### **List Variable**
```hcl
variable "allowed_ips" {
  type    = list(string)
  default = ["192.168.1.1", "192.168.1.2"]
}

resource "aws_security_group" "example" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }
}
```
- Creates a security group rule to allow SSH access from the given IPs.

---

##### **Map Variable**
```hcl
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "t2.large"
  }
}

resource "aws_instance" "example" {
  instance_type = var.instance_types[var.environment]
}
```
- Selects the instance type based on the environment.

---

##### **Object Variable**
```hcl
variable "app_config" {
  type = object({
    name         = string
    version      = string
    enable_debug = bool
  })
  default = {
    name         = "my-app"
    version      = "1.0.0"
    enable_debug = true
  }
}

output "app_details" {
  value = "${var.app_config.name}, version: ${var.app_config.version}"
}
```
- Allows defining complex configurations with multiple attributes.

---

#### **2. Conditional Expressions**

##### **Conditional Instance Type**
```hcl
resource "aws_instance" "example" {
  instance_type = var.is_production ? "t3.large" : "t3.micro"
}
```
- Chooses a larger instance type for production environments.

---

##### **Conditional Resource Creation**
```hcl
resource "aws_ebs_volume" "example" {
  count = var.enable_ebs ? 1 : 0
  size  = 100
}
```
- Creates an EBS volume only if the `enable_ebs` variable is true.

---

##### **Conditional Output**
```hcl
output "database_endpoint" {
  value = var.environment == "production" ? aws_rds_instance.prod.endpoint : "localhost"
}
```
- Returns the production database endpoint or `localhost` for non-production environments.

---

##### **Dynamic Tags**
```hcl
resource "aws_instance" "example" {
  tags = var.is_production ? 
    { Environment = "production", Owner = "admin" } : 
    { Environment = "development", Owner = "developer" }
}
```
- Assigns different tags based on the environment.

---

##### **Using Condition with Lists**
```hcl
variable "region" {
  default = "us-east-1"
}

output "available_amis" {
  value = var.region == "us-east-1" ? ["ami-123", "ami-456"] : ["ami-789", "ami-101"]
}
```
- Outputs a list of AMIs based on the selected region.

---

##### **Count with Conditional Logic**
```hcl
resource "aws_instance" "example" {
  count = var.environment == "production" ? 3 : 1
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```
- Deploys three instances for production, but only one for other environments.

---

These examples demonstrate how variables and conditional expressions can be used in various scenarios to dynamically configure infrastructure resources based on user inputs and conditions.
