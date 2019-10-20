# terraform-azurerm-postgresql-read-replica

 A module to manage Azure Database for PostgreSQL Read Replica until support for PostgreSQL read replicas is implemented. See issue [terraform-provider-azurerm#2819](https://github.com/terraform-providers/terraform-provider-azurerm/issues/2819) for more details.

## Limitations

- Changes outside of terrafrom are not detected and re-applying will not resolve this.
- It's not yet possible to break replication and turn the replica into a primary server.
- It's not yet possible to specify a different location i.e. cross region replication.

Example

```hcl
resource "azurerm_resource_group" "demo" {
  location = "uksouth"
  name     = "demo"
}

resource "azurerm_postgresql_server" "demo" {
  name                = "pr1mary-demo"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  ... # shortened for brevity, see the Azure Provider documentation for more details
}

module postgresql-read-replica {
    source = "booyaa/terraform-azurerm-postgresql-read-replica
    resource_group_name = azurerm_resource_group.demo.name
    server-name       = azurerm_postgresql_server.demo.name
    read-replica-nam = "${azurerm_postgresql_server.demo.name}-replica"
}

resource "azurerm_postgresql_firewall_rule" "demo-replica" {
  name                = "google"
  resource_group_name = azurerm_resource_group.demo.name
  server_name         = module.postgresql-read-replica.replica_name
  start_ip_address    = "8.8.8.8"
  end_ip_address      = "8.8.8.8"
  depends_on          = [module.postgresql-read-replica]
}
```
