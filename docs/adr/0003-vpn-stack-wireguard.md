# ADR-0003: VPN 스택 선택 — WireGuard

## Status

**Accepted** — 2026-04-22

## Context

ADR-0001에서 하이브리드 아키텍처를 채택했다. AWS EKS(컴퓨트)와
온프레 SRV-1(개인정보 DB)을 연결하는 VPN 터널이 필요하다.

연결 수단을 선택할 때 다음 제약이 존재한다.

1. **공인 IP 미할당** — SRV-1은 가정용 ISP(LG U+) 회선 뒤에 위치하며
   고정 공인 IP가 없다. DDNS를 통해 도메인은 확보되어 있다.
2. **기존 인프라** — ASUS 공유기에 WireGuard 서버가 이미 구축되어 있으며,
   외부에서 WireGuard 클라이언트로 SRV-1 접근이 검증된 상태이다.
3. **비용 제약** — 학원 AWS 계정을 사용하므로 월정액 관리형 서비스 비용은
   최소화해야 한다.
4. **IaC 재현성** — 모든 인프라는 코드로 재현 가능해야 한다 (ADR-0005).

## Options Considered

### Option 1: AWS Direct Connect

AWS와 온프레 간 전용 물리 회선.

- 장점: 안정적 대역폭, 낮은 레이턴시, 엔터프라이즈 표준
- 단점: 프로비저닝에 수 주 소요, 월정액 비용 발생,
  물리 회선이므로 IaC로 관리 불가, 개인 프로젝트에 비현실적

### Option 2: AWS Site-to-Site VPN (관리형)

AWS에서 제공하는 관리형 IPsec VPN 서비스.

- 장점: AWS 콘솔/Terraform으로 관리 가능, 이중화 기본 제공
- 단점: Customer Gateway 설정에 **고정 공인 IP 필요** — 현 환경에서
  사용 불가. 시간당 과금($0.05/h ≒ 월 $36)도 부담 요소

### Option 3: WireGuard 직접 구성 (채택)

EKS 내 게이트웨이 파드에서 기존 공유기 WireGuard 서버로 outbound 터널.

- 장점: 기존 인프라 활용, 공인 IP 불필요(outbound 연결),
  경량 프로토콜, 설정이 K8s 매니페스트로 관리 가능
- 단점: 직접 운영 부담, 공유기 WireGuard 서버에 대한 의존,
  터널 장애 시 자체 대응 필요

## Decision

**Option 3 (WireGuard 직접 구성) 채택.**

### 구성 방식

- EKS 내 WireGuard 게이트웨이를 **Deployment (replicas: 2)** 로 배포
- 게이트웨이 파드가 공유기 WireGuard 서버에 outbound 연결
- 앱 파드는 게이트웨이 파드를 통해 SRV-1 PostgreSQL에 접근
- 공유기 WireGuard에 AWS용 peer 추가

### Deployment를 선택한 이유

DaemonSet(노드마다 1개)이 아닌 Deployment를 선택한다.
게이트웨이는 노드 수와 무관하게 2개면 충분하며,
노드 스케일 시 불필요한 게이트웨이 증가를 방지한다.
replicas: 2로 노드 장애 시 가용성을 확보하되,
실제 장애 동작 검증은 Phase 4에서 수행 예정이다.

## Rationale

- **현실 제약 최적화**: 공인 IP 없음 + 비용 제약이라는 두 조건을
  동시에 만족하는 유일한 선택지이다.
- **기존 검증 완료**: 공유기 WireGuard 서버가 동작 중이며
  외부 접속이 확인된 상태이므로 추가 인프라 구축이 최소화된다.
- **쿠버네티스 정합성**: VM 레벨이 아닌 파드 레벨에서 VPN을 관리하여
  EKS의 관리 체계와 일관성을 유지한다.

## Consequences

### 장점

- WireGuard의 낮은 오버헤드로 VPN 자체의 레이턴시 영향 최소화
- K8s 매니페스트로 VPN 설정을 관리하므로 IaC 재현성 확보
- Phase 4에서 VPN 터널 단절 시나리오를 Chaos Engineering 재료로 활용 가능

### 감수할 트레이드오프

- 공유기 WireGuard 서버가 SPOF — 공유기 장애 시 DB 연결 전체 단절
- DDNS 갱신 지연 시 터널 재연결에 시간 소요 가능
- AWS 관리형 서비스 대비 운영 부담이 개인에게 귀속됨

### 후속 작업

- 공유기 WireGuard에 AWS용 peer 설정 추가
- EKS WireGuard 게이트웨이 Deployment 매니페스트 작성
- 앱 파드 → 게이트웨이 → SRV-1 경로의 네트워크 정책 설정
- Phase 4에서 VPN 터널 단절 시 앱 동작 검증
