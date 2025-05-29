module "vpc" {
  source               = "./modules/network"
  environment          = var.environment   # e.g., "dev","test","prod"
  project              = var.project       # e.g., "hr"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  tags = {
    Environment = var.environment    
  } 
}

module "hr_cluster" {
  source               = "./modules/ecs_cluster"
  environment          = var.environment
  cluster_name_suffix  = "hr"
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnets
  vpc_id               = module.vpc.vpc_id  
}
