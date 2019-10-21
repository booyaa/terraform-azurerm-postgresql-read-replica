# terraform-azurerm-postgresql-read-replica

 A module to manage Azure Database for PostgreSQL Read Replica until support for PostgreSQL read replicas is implemented. See issue [terraform-provider-azurerm#2819](https://github.com/terraform-providers/terraform-provider-azurerm/issues/2819) for more details.

## Limitations

- The module is dependant on the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- Changes outside of Terraform are not detected, and re-applying does not resolve this.
- It's not yet possible to break replication and turn the replica into a primary server.
- It's not yet possible to specify a different location, i.e. cross-region replication.
- You cannot use this module to import an existing read replica.

## Example

The following example creates a read replica in the same location as the primary, and adds a firewall rule to the read replica.

```hcl
resource "azurerm_resource_group" "demo" {
  location = "uksouth"
  name     = "demo"
}

resource "azurerm_postgresql_server" "demo" {
  name                = "pr1mary-demo"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  ... # shortened for the sake of brevity, see the Azure provider documentation for more details
}

module demo-replica {
  source                         = "booyaa/terraform-azurerm-postgresql-read-replica"
  resource_group_name            = azurerm_resource_group.demo.name
  postgresql_primary_server_name = azurerm_postgresql_server.demo.name
  postgresql_replica_server_name = "${azurerm_postgresql_server.demo.name}-replica"
}

resource "azurerm_postgresql_firewall_rule" "demo-replica" {
  name                = "office"
  resource_group_name = azurerm_resource_group.demo.name
  server_name         = module.demo-replica.replica_name
  start_ip_address    = "8.8.8.8"
  end_ip_address      = "8.8.8.8"

  depends_on = [module.demo-replica]
}
```

## Copyright

Mark Sta Ana &copy; 2019
