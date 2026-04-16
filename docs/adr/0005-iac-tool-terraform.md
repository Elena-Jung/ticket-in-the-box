# ADR-0005: IaC 도구 — Terraform (HashiCorp 공식 배포판)

## Status

**Accepted** — 2026-04-15

## Context

본 프로젝트의 IaC 도구 선택은 2023년 8월 HashiCorp의 라이선스 변경
(MPL → BSL) 이후 의미 있는 결정이 되었다. 동일 코드베이스에서 fork된
**OpenTofu** 역시 등장하였다.

추가로 Homebrew의 `brew install terraform`이 BSL 정책으로 인해
공식 tap (`hashicorp/tap`) 경유 설치를 요구하는 등, 도구 선택이
운영 단계의 마찰까지 동반한다.

## Options Considered

### Option 1: Terraform (HashiCorp 공식, BSL)

- 장점: 업계 표준, 인지도 압도적, 모든 Provider의 1차 지원 대상,
  공식 docs/예제가 풍부
- 단점: BSL 라이선스 (Production 사용엔 무관, 경쟁 SaaS 서비스 빌드만 제약)

### Option 2: OpenTofu (Linux Foundation, MPL)

- 장점: 완전 오픈소스 라이선스 유지, Terraform 호환,
  HashiCorp 라이선스 위험에서 자유
- 단점: 인지도 약함, 일부 신규 Provider 기능이 늦게 동기화될 수 있음,
  명령어가 `tofu`로 달라 학습 자료/도구 통합 시 번역 필요

### Option 3: Pulumi

- 장점: 일반 프로그래밍 언어 사용 (Python, TS, Go 등)
- 단점: HCL 기반 Terraform 생태계와 단절, Provider/모듈 풍부함 ↓

## Decision

**Option 1 (Terraform)** 채택. 공식 HashiCorp tap 경유 설치
(`brew install hashicorp/tap/terraform`).

## Rationale

- **포트폴리오 인지도**: 채용담당자/면접관에게 "Terraform"이라는 단어가 주는
  인지 가중치가 OpenTofu보다 압도적으로 큼 (2025년 현재 기준).
- **레퍼런스 코드 풍부**: `terraform-aws-modules` 등 공식 모듈, AWS 공식
  예제, Provider 문서가 모두 Terraform을 1차 기준으로 작성.
- **본 프로젝트 용도**: 학습/포트폴리오/개인 사용은 BSL의 "경쟁 제품 빌드"
  조항과 무관하므로 라이선스 위험 없음.

## Consequences

### 장점
- HashiCorp의 공식 모듈 생태계 즉시 활용

### 감수할 트레이드오프

- BSL 라이선스 미래 변화 가능성 모니터링 필요
- HashiCorp가 라이선스를 더 제한적으로 변경하면 OpenTofu로 마이그레이션 필요할 수 있음
- 그 마이그레이션 비용은 현재로선 0에 가까움 (HCL 호환)

### 후속 작업

- HashiCorp 라이선스 정책 분기별 점검
- Terraform 신규 메이저 버전 (예: 2.x) 출시 시 호환성 검토