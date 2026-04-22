import http from 'k6/http';

export const options = {
    // 여기에 시나리오 정의 (몇 명, 얼마나 오래)
    vus: 10,
    duration : '60s'
};

export default function () {
    // 여기에 실제 요청
    http.get('http://k8s-default-sampleap-c6ef49208e-1258629478.ap-northeast-2.elb.amazonaws.com');
}