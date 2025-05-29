output "hr_cluster_name" {
  value = module.hr_cluster.ecs_cluster_name
}

output "hr_capacity_provider_name" {
  value = module.hr_cluster.capacity_provider_name
}
