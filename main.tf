resource "azurerm_resource_group" "rgropra" {
    for_each = var.rg
  name     = each.value.name
  location = each.value.location
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  depends_on = [ azurerm_resource_group.rgropra ]
  for_each = var.rg
  name                = each.value.acrname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Container Instance
resource "azurerm_container_group" "aci" {
  depends_on = [azurerm_container_registry.acr, azurerm_resource_group.rgropra]
  for_each = var.rg
  name                = each.value.aciname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "mycontainer"
    image  = "${azurerm_container_registry.acr.login_server}/my-app:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  # Set the type of IP address for the container group
  ip_address_type = "public"

  # Ports should be configured inside the container block
  # Note: No need for a top-level `ports` block here
}
