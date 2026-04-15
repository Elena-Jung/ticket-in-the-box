# ─── Observability Stack ───
# kube-prometheus-stack: Prometheus + Grafana + Alertmanager
#                        + Node Exporter + kube-state-metrics

# 전용 namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Helm release
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "65.5.1"   # 2024년 말 안정 버전
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Helm values (아래는 커스텀, 나머지는 chart 기본값)
  values = [
    yamlencode({
      grafana = {
        # Phase 1 학습용 임시 비밀번호 (Phase 3에서 Secret으로 교체 예정)
        adminPassword = "admin-phase1-change-later"

        # port-forward로만 접근 (Ingress는 Journey 5에서 추가)
        service = {
          type = "ClusterIP"
        }

        defaultDashboardsEnabled = true
      }

      prometheus = {
        prometheusSpec = {
          # 학습용 짧은 retention (기본 15d → 7d)
          retention = "7d"

          # 스토리지는 EmptyDir (재시작 시 데이터 소실)
          # Phase 4에서 PersistentVolume으로 전환 예정
        }
      }

      alertmanager = {
        enabled = true
      }
    })
  ]

  # EKS가 완전히 준비된 후에 설치
  depends_on = [module.eks]

  # CRD + Pod 기동 시간 여유 (기본 5분 → 15분)
  timeout = 900
}

# Grafana 접속 편의를 위한 output
output "grafana_port_forward_cmd" {
  description = "Grafana 접속용 kubectl port-forward 명령"
  value       = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
}

output "grafana_admin_username" {
  description = "Grafana 초기 관리자 계정 (admin)"
  value       = "admin"
}

output "grafana_admin_password_note" {
  description = "Grafana 초기 관리자 비밀번호 위치"
  value       = "observability.tf 내 values.grafana.adminPassword 참조 (학습용 임시)"
}