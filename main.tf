resource "null_resource" "postgresql-read-replica" {
  triggers = {
    resource_group_name            = var.resource_group_name
    postgresql_primary_server_name = var.postgresql_primary_server_name
    postgresql_replica_server_name = var.postgresql_replica_server_name
  }

  # enables replication on the primary server
  provisioner "local-exec" {
    command = <<ENABLE_REPLICATION
az postgres server configuration set \
  --resource-group ${var.resource_group_name} \
  --server-name ${var.postgresql_primary_server_name} \
  --name azure.replication_support --value REPLICA
ENABLE_REPLICATION
  }

  # restart primary for change to take effect
  provisioner "local-exec" {
    command = <<RESTART_SERVER
az postgres server restart \
  --name ${var.postgresql_primary_server_name} \
  --resource-group ${var.resource_group_name}
RESTART_SERVER
  }

  # create replica
  provisioner "local-exec" {
    command = <<CREATE_REPLICA
az postgres server replica create \
  --name ${var.postgresql_replica_server_name} \
  --source-server ${var.postgresql_primary_server_name} \
  --resource-group ${var.resource_group_name}
CREATE_REPLICA
  }

  provisioner "local-exec" {
    when = "destroy" 
    command = <<DESTROY_REPLICA
az postgres server delete \
  --name ${var.postgresql_replica_server_name} \
  --resource-group ${var.resource_group_name} \
  --yes
DESTROY_REPLICA    
  }
}
