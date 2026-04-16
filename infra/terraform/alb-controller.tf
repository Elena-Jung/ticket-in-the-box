# ─── AWS Load Balancer Controller ───
# Ingress 리소스를 감시하여 ALB를 자동 생성/관리하는 컨트롤러.
# IRSA(IAM Roles for Service Accounts)로 최소 권한 원칙 적용.

# ─── 1. IAM Policy ───
# ALB/NLB/TargetGroup 등 AWS API 호출에 필요한 권한.
# 별도 JSON 파일로 분리하여 가독성 확보.
resource "aws_iam_policy" "alb_controller" {
  name        = "policy-alb-controller"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/alb-iam-policy.json")
}

# ─── 2. IAM Role (IRSA) ───
# OIDC 신뢰 관계: "이 ServiceAccount를 가진 파드만 이 Role을 사용할 수 있다"
resource "aws_iam_role" "alb_controller" {
  name = "role-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:sa-alb-controller"
          }
        }
      }
    ]
  })
}

# ─── 3. Role ↔ Policy 연결 ───
resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# ─── 4. Helm Release ───
# ALB Controller 설치. ServiceAccount에 IAM Role ARN을 annotation으로 주입.
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.11.0"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "sa-alb-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [
    aws_iam_role_policy_attachment.alb_controller,
    module.eks,
  ]
}
