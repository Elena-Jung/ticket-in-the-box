# Runbook - 개인 정리목적
last modified - 20260417

## 테라폼

### 테라폼이란
테라폼은 HashiCorp 사의 IaC 도구
명령형이 아닌 선언형으로써, 여러번 행동을 지시하여도 여러번 만드는것이 아닌, 선언된 내용중 빈 내용을 채우는 형태로 진행함

### vs Opentofu
HashiCorp 사가 라이센스를 변경함에 따라 오픈소스 OpenTofu와 같은 오픈소스 프로젝트들이 출범하였다

### 테라폼 작동 구문
terraform init


terraform plan
비실행, 어떻게 진행되는가를 ***확인만*** 함

terraform apply
실행, 실제로 테라폼 구문을 통하여 선언된 내용을 진행함. yes를 입력하여 실제 작동을 승인하여야 함

terraform desroy
실행, 테라폼을 통해 구성하였던 내용을 삭제함. yes를 입력하여 실제 작동을 승인하여야 함

*주의사항* : 테라폼의 eks 형성이 선행 작업들이 실제 프로비저닝 되기 전 형성되려고 할 수 있음, 
실패시 terraform apply를 한번 더 하여 선언 내용을 다시 진행시키면 가능함.
명령형이 아닌 선언형이기에 다시 실행하여도 두개가 만들어지는것이 아닌, 선언된 내용들 중 없는 부분을 채워가는 형식.
그렇기에 더더욱이 CI/CD 파이프라인 구축 및 자동 배포가 중요함.

## Git

### Github 주의사항

### Git 명령어

git init
프로젝트 버전 관리 시작

git status

git add (추가할 오브젝트 또는 폴더)

git commit
커밋(버전 생성), 현 작업 내용을 하나의 버전으로 기록
-m ''   : message, 코멘트를 달 수 있음
--amend : 이전 커밋을 현 커밋으로 덮어쓰기, (이후 git push -f 필요)

git push
push(로컬 레지스트리 -> 원격 레지스트리), 
-f  : 이상한거 했다가 수습할때, 보통 막히는덴 이유가 있어서 막히는것이기에 사이드이펙트를 모두 확인하고 확실할때만 진행

git pull --rebase origin main
원격 레지스트리에서 로컬로 불러오는 형태
--rebase  : 

## K8S

### K8S 명령어

kubectl get nodes
노드 정보 불러오기

kubectl get pods -n monitoring
팟 모니터링 정보 불러오기
-n  : 네임스페이스 

kubectl delete -f k8s/sample-app/
k8s/sample-app/ 에서 지정된 내용을 강제 삭제, 이를 하여야지만 Ingress가 먼저 삭제됨, 그 뒤에 테라폼 삭제하여야 함

kubectl describe (nodes/pods) (객체명)
상세정보 출력


## AWS CLI

### AWS CLI 명령어

aws configure
aws cli 로그인, 각각 Access key ID, Secret Access key, default region name, default output format 넷을 요구함.

aws eks update-kubeconfig --name eks-main --region ap-northeast-2
~/.kube/config의 클러스터의 엔드포인트를 지금 구성된 EKS 클러스터의 엔드포인트로 재지정