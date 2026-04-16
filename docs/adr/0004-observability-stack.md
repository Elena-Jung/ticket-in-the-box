# ADR-0004: Observability 스택 — kube-prometheus-stack via Helm

## Status

**Accepted** — 2026-04-15

## Context

Phase 1의 핵심 산출물 중 하나는 **"클러스터/앱의 상태를 측정 가능한 시스템"**
이다. Phase 4의 Performance Engineering과 Chaos Engineering 모두
**baseline 측정 → 변경 → 비교**의 사이클을 전제하므로, 관측 스택은
프로젝트의 가장 이른 시점부터 안정적으로 동작해야 한다.

또한 ADR-0001에서 정의한 "Layer A: Performance Engineering 연속성"은
Phase 1부터 시작되어야 하며, 이는 모든 Phase에서 동일한 메트릭을
일관되게 수집할 수 있는 기반을 요구한다.

## Options Considered

### Option 1: 개별 컴포넌트 수동 설치

Prometheus, Grafana, Alertmanager, Node Exporter, kube-state-metrics를
각각 별도 Helm chart 또는 manifest로 설치.

- 장점: 각 컴포넌트 이해도가 깊어짐, 커스터마이즈 자유도 ↑
- 단점: 통합 관리 부재, 버전 호환성 지속 점검 필요,
  ServiceMonitor CRD 등 별도 설치 부담

### Option 2: kube-prometheus-stack (채택)

Prometheus Community가 관리하는 통합 Helm chart. Prometheus,
Grafana, Alertmanager, Node Exporter, kube-state-metrics, Prometheus
Operator + 관련 CRD를 한 번에 배포.

- 장점: 산업 표준 (de-facto), 통합 관리, ServiceMonitor 등 CRD 포함,
  업스트림 보안/버전 관리, Grafana 기본 대시보드 자동 프로비저닝
- 단점: chart 내부 구조가 복잡해서 디버깅이 학습 곡선 있음

### Option 3: 관리형 서비스 (DataDog, New Relic 등)

- 장점: 운영 부담 0, 수많은 통합 기본 제공
- 단점: 유료, 데이터 외부 전송 (CSAP 명분과 충돌), IaC 학습 목적과 부적합

## Decision

**Option 2 (kube-prometheus-stack)** 채택, **Terraform helm provider**로
설치한다. 즉:

- chart: `prometheus-community/kube-prometheus-stack`
- version: `65.5.1` (2024년 말 안정 버전)
- namespace: `monitoring` (전용 분리)
- 설치 방식: `helm_release` 리소스 (선언형 일관성)

## Rationale

- **산업 표준**: 사실상 K8s 모니터링의 기본 구성. 이력서에 별도 설명 불필요.
- **선언형 일관성**: ADR-0001에서 표명한 "Declarative First" 원칙 준수.
  helm CLI 직접 사용은 Terraform state 밖에 리소스를 두게 되어 부적절.
- **재현성**: terraform destroy/apply 한 사이클로 관측 스택 전체 재구성.
- **CSAP 명분과 일관**: 데이터가 클러스터 안에 머무름 (외부 SaaS 송신 없음).

## Consequences

### 장점

- Phase 1 종료 시점에 즉시 baseline 측정 가능
- Phase 4의 모든 실험이 동일한 메트릭 인프라 위에서 진행됨
- ServiceMonitor CRD를 통해 Phase 2 이후 앱 메트릭을 선언적으로 수집 가능

### 감수할 트레이드오프

- chart 자체가 무거움 (t3.medium × 2 환경에서 약 2~3GB 메모리 점유)
  → Phase 4에서 이게 워크로드와의 자원 경쟁을 일으킬 가능성 있음
- chart 업그레이드 시 CRD 호환성 점검 필요
- Prometheus 데이터를 EmptyDir에 저장 (Phase 1 단순화) → Pod 재기동 시 데이터 손실
  → Phase 4 진입 전 PersistentVolume으로 전환 필요 (별도 ADR 예정)

### 후속 작업

- ADR-XXXX: Prometheus 스토리지 PV 전환 (Phase 4 전)
- ADR-XXXX: Alertmanager 알림 라우팅 설정 (Phase 3)
- Runbook: kube-prometheus-stack 첫 apply 시 권한 캐싱 이슈 (이미 발생)