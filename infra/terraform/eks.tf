data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-main"
  cluster_version = "1.32"

  # VPC 정보 (vpc 모듈 output 참조)
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # API 엔드포인트 접근
  cluster_endpoint_public_access  = true   # 학습/포트폴리오 편의
  cluster_endpoint_private_access = true

  # 클러스터 생성자에게 자동으로 cluster-admin 권한 부여
  enable_cluster_creator_admin_permissions = true

  # Managed Node Group (AWS가 EC2 수명주기 관리)
  eks_managed_node_groups = {
    main = {
      ami_type       = "AL2023_x86_64_STANDARD"   # Amazon Linux 2023
      instance_types = ["t3.medium"]              # 4GB RAM, 2 vCPU

      min_size     = 1
      max_size     = 3
      desired_size = 2

      tags = {
        Name = "eks-main-workers"
      }
    }
  }

  # EKS가 관리하는 Add-on들 (수동 설치보다 안정적)
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }
}