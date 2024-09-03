resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = var.common_tags

}

module "vnet" {
  source = "./modules/vnet"

  vnet_name           = var.vnet_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  vnet_address_space  = var.vnet_address_space
  tags                = var.common_tags
}

module "subnet" {
  source = "./modules/subnet"

  vnet_name             = module.vnet.vnet_name
  resource_group_name   = azurerm_resource_group.resource_group.name
  subnet_name           = var.subnet_name
  subnet_address_prefix = var.subnet_address_prefix
}
