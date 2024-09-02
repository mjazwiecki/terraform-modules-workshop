# Introduction to Terraform Automation workshop
# References
1. Hashicorp documentation: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

# 1. Create folder for your work
```
mkdir -p terrarform-automation-intro-workshop
cd terrarform-automation-intro-workshop
```
# 2. Initialise git repo
```
git init
```
Create `.gitignore` file for you Terraform project:
```
touch .gitignore
echo "# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Exclude all .tfvars files, which are likely to contain sentitive data, such as
# password, private keys, and other secrets. These should not be part of version
# control as they are data points which are potentially sensitive and subject
# to change depending on the environment.
*.tfvars

# Ignore override files as they are usually used to override resources locally and so
# are not checked in
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore Terraform .tfstate.d directories
**/.tfstate.d/*

# Ignore pre-commit configuration file
.pre-commit-config.yaml" >> .gitignore
```
# 3. Create configuration for pre-commit

```
touch .pre-commit-config.yaml
echo "repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.6.0

  hooks:
  - id: trailing-whitespace

- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.94.0

  hooks:
  - id: terraform_fmt
    args:
    - --args=-no-color
    - --args=-diff
    - --args=-write=true

  - id: terraform_docs
    args:
    - --hook-config=--path-to-file=README.md
    - --hook-config=--add-to-existing-file=true
    - --hook-config=--create-file-if-not-exist=true

  - id: terraform_tflint
    args:
    # - --args=--module
    # https://github.com/terraform-linters/tflint/tree/master/docs/rules#rules
    - --args=--only=terraform_deprecated_interpolation
    - --args=--only=terraform_deprecated_index
    - --args=--only=terraform_unused_declarations
    - --args=--only=terraform_comment_syntax
    - --args=--only=terraform_documented_outputs
    - --args=--only=terraform_documented_variables
    - --args=--only=terraform_typed_variables
    - --args=--only=terraform_module_pinned_source
    - --args=--only=terraform_naming_convention
    - --args=--only=terraform_required_version
    - --args=--only=terraform_required_providers
    - --args=--only=terraform_standard_module_structure
    - --args=--only=terraform_workspace_remote
    - --args=--only=terraform_unused_required_providers
    - --args=--only=terraform_comment_syntax" >> .pre-commit-config.yaml
```


# 4.Create folder structure for you Terrafrom configuration:
```
touch {main,outputs,variables,versions}.tf
```
# 5. Configure Terraform and AzureRM provider
Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#example-usage

```
# Query the installed Terraform version and extract the version number
TF_VERSION=$(terraform version -json | jq -r .terraform_version)

# Write the provided Terraform configuration into terrarform-automation-intro-workshop/versions.tf
cat <<EOL > versions.tf
terraform {
  required_version = "= $TF_VERSION"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.0.1"
    }
  }
}

provider "azurerm" {
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
  features {}
}
EOL
```

# 6. Write code to deploy resource group
Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
```
# Add the azurerm_resource_group resource to terrarform-automation-intro-workshop/main.tf
echo 'resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = var.common_tags

}' >> main.tf
```

```
# Write the provided variables configuration into terrarform-automation-intro-workshop/variables.tf
cat <<EOL > variables.tf
variable "subscription_id" {
  description = "The subscription ID to use"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
  default     = "West Europe"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags to apply."
  default = {
    Provisioner = "Terraform"
    Environment = "Workshop"
  }
}
EOL
```



# 7. Use terraform.tfvars for variables substitution
Reference: https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files
```
# Write the provided variables into terrarform-automation-intro-workshop/terraform.tfvars
cat <<EOL > terraform.tfvars
subscription_id         = "{fill in with your subscription id}"
resource_group_name     = "rg-terraform-workshop"
resource_group_location = "Poland Central"
EOL
```

# 8. Deploy resource group
1. Log into Azure
```
az login
```
2. Initialise Terraform
```
terraform init
```
3. Validate changes shown by Terraform plan
```
terraform plan
```
4. Apply changes
```
terraform apply
```

# 9. Build vnet module
Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
```
cd modules
mkdir -p vnet && cd vnet && touch {main,outputs,variables,versions}.tf
```
```
# Write the provided Terraform resources into terrarform-automation-intro-workshop/modules/vnet/main.tf
cat <<EOL > main.tf
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}
EOL
```
Fill in needed variables into variables.tf
```
# Write the provided variables configuration into terrarform-automation-intro-workshop/modules/vnet/variables.tf
cat <<EOL > variables.tf
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "location" {
  description = "Location of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space of the virtual network"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the virtual network"
  type        = map(string)
}
EOL
```
Create output for vnet name
```
# Fill in outputs into terrarform-automation-intro-workshop/modules/vnet/outputs.tf
cat <<EOL > outputs.tf
output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "Name of the virtual network"
}
EOL
```
Pin azurerm terraform and provider version:
```
# Query the installed Terraform version and extract the version number
TF_VERSION=$(terraform version -json | jq -r .terraform_version)

# Write the provided Terraform configuration into terrarform-automation-intro-workshop/modules/vnet/versions.tf
cat <<EOL > versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.0.1"
    }
  }
}
EOL
```
Add a vnet module call into terrarform-automation-intro-workshop/main.tf
```
# Append the provided module call into main.tf
cat <<EOL >> main.tf

module "vnet" {
  source = "./modules/vnet"

  vnet_name           = var.vnet_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  vnet_address_space  = var.vnet_address_space
  tags                = var.common_tags
}
EOL
```
Add vnet related variable values into terraform.tfvars
```
# Append the provided variables to terrarform-automation-intro-workshop/terraform.tfvars
cat <<EOL >> terraform.tfvars
vnet_name               = "vnet-terraform-workshop"
vnet_address_space      = ["10.0.0.0/16"]
EOL
```
# 10. Deploy vnet into your resource group

1. Initialise Terraform
```
terraform init
```
2. Validate changes shown by Terraform plan
```
terraform plan
```
3. Apply changes
```
terraform apply
```

# 11. Build subnet module
Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
```
cd modules
mkdir -p subnet && cd subnet && touch {main,outputs,variables,versions}.tf
```
```
# Write the provided Terraform resources into terrarform-automation-intro-workshop/modules/subnet/main.tf
cat <<EOL > main.tf
resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_address_prefix]
}
EOL
```
Fill in needed variables into terrarform-automation-intro-workshop/modules/subnet/variables.tf
```
# Write the provided variables configuration into terrarform-automation-intro-workshop/modules/subnet/variables.tf
cat <<EOL > variables.tf
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the first subnet"
  type        = string
}

variable "subnet_address_prefix" {
  description = "Address prefix of the subnet"
  type        = string
}
EOL
```
Pin azurerm terraform and provider version:
```
# Query the installed Terraform version and extract the version number
TF_VERSION=$(terraform version -json | jq -r .terraform_version)

# Write the provided Terraform configuration into terrarform-automation-intro-workshop/modules/subnet/versions.tf
cat <<EOL > versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.0.1"
    }
  }
}
EOL
```
Add a subnet module call into terrarform-automation-intro-workshop/main.tf
```
# Append the provided module configuration into main.tf
cat <<EOL >> main.tf

module "subnet" {
  source = "./modules/subnet"

  vnet_name             = module.vnet.vnet_name
  resource_group_name   = azurerm_resource_group.resource_group.name
  subnet_name           = var.subnet_name
  subnet_address_prefix = var.subnet_address_prefix
}
EOL
```
Add subnet related variable values into terrarform-automation-intro-workshop/terraform.tfvars
```
# Append the provided variables to terraform.tfvars
cat <<EOL >> terraform.tfvars
subnet_name             = "subnet-terraform-workshop"
subnet_address_prefix   = "10.0.0.0/24"
EOL
```
# 10. Deploy subnet into your vnet

1. Initialise Terraform
```
terraform init
```
2. Validate changes shown by Terraform plan
```
terraform plan
```
3. Apply changes
```
terraform apply
```