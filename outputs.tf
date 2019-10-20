output replica_name {
  description = "Returns the name of the PostgreSQL read replica server."
  value       = "${var.postgresql_replica_server_name}"
}