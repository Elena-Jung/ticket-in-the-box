# ticket-in-the-box

> Hybrid cloud ticketing platform — a portfolio project exploring declarative
> infrastructure, data sovereignty patterns, and performance engineering.

---

## 왜 이 프로젝트인가 (Context)

국내 티켓팅 도메인은 다음 세 가지 특성을 동시에 가진다.

- **극단적 트래픽 스파이크** — 오픈 시점에 집중, 평시는 저트래픽
- **민감 개인정보 처리** — 결제, 본인 인증, 배송지
- **CSAP 하등급 제약** — 클라우드에 특정 데이터 저장 제약

이 프로젝트는 위 특성을 가진 **가상 리그 티켓팅 서비스**를 제작하면서,
하이브리드 클라우드 아키텍처(온프레 DB + AWS 컴퓨트)를 통해
**데이터 주권과 탄력적 운영을 양립**시키는 방법을 탐구한다.

## 선언적 접근 (Declarative Philosophy)

이 프로젝트의 모든 설계 결정은 다음 원칙을 따른다.

1. **Desired State First** — 최종 증거물과 목표 수치를 먼저 선언하고, 거기에 맞춰 역산한다.
2. **Infrastructure as Code** — 모든 인프라는 Terraform으로 관리. 학원 AWS 계정이 사라져도 재현 가능해야 한다.
3. **Decision as Document** — 모든 주요 기술 결정은 [ADR](./docs/adr/)로 기록된다. 결정이 일어나는 시점에 쓰고, 나중에 덧붙이지 않는다.
4. **Measurement over Assertion** — "잘한다"는 주장 대신 숫자와 그래프로 증명한다.

## 아키텍처 개요

> TBD — Phase 1 진입 시 다이어그램 추가 예정 (ADR-0002 결정 후)

```
[온프레 SRV-1]                           [AWS]
PostgreSQL (개인정보 원본)  ⟷ VPN ⟷  EKS (애플리케이션)
Tokenization Service                     Prometheus / Grafana
Column Encryption                        Ingress / ALB
```

## Phase 구조

이 프로젝트는 4개의 Phase로 진행되며, **각 Phase 종료 시점이 중단 가능한 체크포인트**다.

| Phase | 이름 | 핵심 산출물 |
|-------|------|-------------|
| 1 | 인프라/관측 기반 | EKS, Prometheus/Grafana, Terraform, baseline 측정 |
| 2 | 하이브리드 연결 | SRV-1 DB, WireGuard, 기본 앱 동작 |
| 3 | 보안 & CI/CD | Tokenization, Column Encryption, ArgoCD |
| 4 | Chaos & Performance | 부하 시나리오, 장애 주입, 최종 리포트 |

각 Phase에는 **성능 측정 체크포인트**가 포함되며, Phase 4에서 baseline 대비
개선치를 종합 리포트로 정리한다.

## 의사결정 (Architecture Decision Records)

모든 중요한 기술 결정은 [docs/adr/](./docs/adr/)에 기록되어 있다.

- [ADR-0001: 하이브리드 클라우드 경계 설정](./docs/adr/0001-hybrid-cloud-boundary.md) — Accepted

## 측정과 결과

> TBD — Phase 4 종료 후 작성

아래 항목에 대해 baseline / 개선 후 수치를 비교 테이블로 제공할 예정.

- HTTP 요청 p50 / p99 레이턴시
- 티켓 오픈 스파이크 시점 처리량 (RPS)
- 장애 감지 ~ 복구 시간 (MTTR)
- Tokenization 오버헤드
- VPN 터널 단절 시 앱 복구 시간

## 재현 방법

> TBD — `scripts/reproduce.sh` 구현 후 작성

## 한계와 향후 과제

> TBD — 각 Phase 종료 시점마다 추가

## 라이선스

개인 포트폴리오 프로젝트. 외부 기여는 현재 받지 않는다.
