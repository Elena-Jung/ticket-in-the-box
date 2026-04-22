# Phase 1 Baseline 측정

## 측정 목적
현 구축된 시스템이 정상적으로 외부 요청을 받을 수 있는지 검증

## 측정 환경

### 인프라 구성
- EKS 버전 :1.32.13-eks-bbe087e
- 노드 : VM - t3.medium 2기
- 샘플 앱 : nginx - nginx 자체 샘플 페이지
  - 이미지 : nginx:1.27-alpine
  - Replicas : 2
  - CPU : request 50m / limit 100m
  - Memory : request 64Mi / limit 128Mi

### 부하 테스트 도구
- 도구 : k6
- 시나리오: vus 10, 60초간

## 부하 테스트 결과 (k6)

### HTTP 응답
- 총 요청 수 : 38395
- 실패율 : 0 (0%)
- 평균 응답 시간 : 15.55ms
- p95 : 18.12ms
- 초당 처리량 : 639.77163/s

## Grafana 메트릭 (USE Method)

### Utilization (사용률)
- CPU : 3.8%
- Memory : 26.7%

### Saturation (포화도)
nginx 기본 정적 페이지 기준으로 진행하였기에 포화상태에 근접한 지표가 없음

### Errors
0회, 에러 없이 모두 정상적인 처리가 됨

## 한계 및 다음 단계
nginx 기본 정적 페이지이며, 컨테이너가 실질적인 서비스를 진행하는것이 아니기에 해당 테스트의 메트릭은 유효한 지표가 아님,
해당 테스트를 통하여 현 구조가 정상적인 플로우를 가짐을 알 수 있음.
