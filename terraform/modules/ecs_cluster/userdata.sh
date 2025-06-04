#!/bin/bash
echo "Rendering user data for ECS cluster: ${cluster_name}" >> /tmp/debug.log

# Write ECS cluster name config
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
