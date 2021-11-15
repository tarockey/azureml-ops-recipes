output "id" {
  description = "The id of the vNet"
  value       = azurerm_virtual_network.this.id
}

output "address_space" {
  description = "The address space of the vNet"
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_id" {
  description = "The id of the subnet"
  value       = join(",", azurerm_subnet.this.*.id)
}
