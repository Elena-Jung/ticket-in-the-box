# Architecture Decision Records

이 디렉토리에는 프로젝트의 주요 기술 결정이 기록된다.

각 ADR은 **결정이 일어나는 시점**에 작성하며, 이후 수정/번복은
별도 ADR로 남긴다 (기존 파일은 Status를 Superseded로 표시).

## 형식

- 파일명: `NNNN-short-kebab-case-title.md`
- 번호는 0001부터 순차, **재사용 금지** (번복 시에도 새 번호 부여)
- Status: `Proposed` / `Accepted` / `Superseded by ADR-NNNN` / `Deprecated`

## 표준 섹션

모든 ADR은 다음 섹션을 포함한다.

- **Status** — 현재 상태와 날짜
- **Context** — 결정이 필요해진 배경과 제약
- **Options Considered** — 고려한 대안들 (최소 2개 이상)
- **Decision** — 선택한 옵션과 그 구체적 내용
- **Rationale** — 왜 이 옵션인가
- **Consequences** — 장점, 단점/감수할 트레이드오프, 후속 작업

## 목록

| 번호 | 제목 | Status | 날짜 |
|------|------|--------|------|
| [0001](./0001-hybrid-cloud-boundary.md) | 하이브리드 클라우드 경계 설정 | Accepted | 2026-04-15 |

## 예정된 ADR

Phase 진행에 따라 추가될 결정들.

- ADR-0002: Data Segregation 전략 (Tokenization + Column Encryption)
- ADR-0003: VPN 스택 선택 (WireGuard 유력)
- ADR-0004: Observability 스택 선택 (Prometheus + Grafana + Loki)
- ADR-0005: CI/CD 방식 (GitHub Actions + ArgoCD)
- ADR-0006: 좌석 동시성 제어 방식 (분산 락 vs 낙관/비관적 락)
