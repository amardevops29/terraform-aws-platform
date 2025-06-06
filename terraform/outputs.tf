output "hr_cluster_name" {
  description = "The name of ECS Cluster."
  value = module.hr_cluster.ecs_cluster_name
}

output "hr_capacity_provider_name" {
  description = "The name of Capacity Provider."
  value = module.hr_cluster.capacity_provider_name
}
