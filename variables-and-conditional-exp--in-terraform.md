#### **1. Variables**
- **Purpose**: To define reusable values that can be customized and passed to Terraform configurations.  
- **Types**:  
  - **Input Variables**: Allow users to input values dynamically.
  - **Environment Variables**: Terraform reads variables from environment variables prefixed with `TF_VAR_`.

- **Syntax**: 
  ```hcl
  variable "variable_name" {
    type        = string
    default     = "default_value"
    description = "Description of the variable"
  }
  ```

- **Usage**: Reference in configuration files using `${var.variable_name}` or `var.variable_name`.

- **Types of Input Variables**:
  - **string**: Single-line text values.
  - **number**: Numeric values.
  - **bool**: Boolean values (`true` or `false`).
  - **list**: Ordered collections of values.
  - **map**: Key-value pairs.

- **Override Hierarchy**:
  1. Command-line flags (e.g., `-var`).
  2. `.tfvars` files.
  3. Environment variables.
 
- ##### **String Variable**
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


---

#### **2. Output**
- **Purpose**: To expose values from a Terraform module to the command line or to other modules.
  
- **Syntax**:
  ```hcl
  output "output_name" {
    value       = resource.attribute
    description = "Description of the output"
  }
  ```

- **Usage**: Run `terraform output` to view the values in the command line after applying a configuration.

- **Example**:
  ```hcl
  output "instance_ip" {
    value = aws_instance.example.public_ip
  }
  ```

---

#### **3. Count**
- **Purpose**: To create multiple instances of a resource or module dynamically based on a variable.

- **Syntax**:
  ```hcl
  resource "resource_type" "resource_name" {
    count = variable_name
    attribute = "value"
  }
  ```

- **Accessing Count**: 
  - Use `count.index` to access the index of each instance.
  
- **Example**:
  ```hcl
  resource "aws_instance" "example" {
    count = 3
    ami           = "ami-123456"
    instance_type = "t2.micro"
  }
  ```

  This will create three instances.

---

#### **4. Data Types**
- **Primitive Types**:
  - `string`: Example: `"Hello World"`
  - `number`: Example: `42`
  - `bool`: Example: `true`

- **Complex Types**:
  - `list`: Ordered collections, e.g., `["a", "b", "c"]`
  - `map`: Unordered key-value pairs, e.g., `{"key1" = "value1", "key2" = "value2"}`
  - `set`: Unordered collections of unique elements.
  - `tuple`: Ordered collections of mixed types.
  - `object`: Collection of named attributes with defined types, e.g.,
    ```hcl
    {
      name = string
      age  = number
    }
    ```

---

#### **5. Conditional Expressions**
- **Purpose**: To create resources or define attributes dynamically based on conditions.

- **Syntax**:
  ```hcl
  condition ? true_value : false_value
  ```

- **Example**:
  ```hcl
  resource "aws_instance" "example" {
    instance_type = var.is_production ? "t2.large" : "t2.micro"
  }
  ```

- **Using with `count` or `for_each`**:
  ```hcl
  count = var.create_instance ? 1 : 0
  ```

---

These concepts are fundamental in making Terraform configurations reusable, modular, and dynamic, enabling infrastructure to be managed efficiently.


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
