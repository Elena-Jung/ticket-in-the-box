data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  # ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-main"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  # NAT Gateway: 비용 절감 위해 single NAT (dev 환경 전제)
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # EKS 호환 태그 (Journey 3에서 AWS Load Balancer Controller가 사용)
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  # 서브넷 이름 커스텀
  public_subnet_names  = ["subnet-public-1a", "subnet-public-1b", "subnet-public-1c"]
  private_subnet_names = ["subnet-private-1a", "subnet-private-1b", "subnet-private-1c"]

  # 네이밍 규칙: <type>-<purpose>
  igw_tags                 = { Name = "igw-main" }
  nat_gateway_tags         = { Name = "nat-main" }
  public_route_table_tags  = { Name = "rt-public" }
  private_route_table_tags = { Name = "rt-private" }
}