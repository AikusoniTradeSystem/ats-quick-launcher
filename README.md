# ats-quick-launcher

AikusoniTradeSystem 앱을 도커를 사용해 배포할 때 사용

### 개요
- Docker Compose를 사용해 손쉽게 앱을 배포 할 수 있다.

### 사용법
- 프로젝트 루트에 예시로 작성된 배치 스크립트를 정렬된 순서대로 실행합니다.
- 05_BASE_* 형태의 스크립트는 공용 스크립트로 05_0000_generate_vault_certs.sh 같은 다른 스크립트가 실행합니다.
- 스크립트는 의존성 순서대로 작성되어 있습니다.
- 관련 서비스를 종료하는 스크립트는 D로 시작합니다. (예: D00_stop_network.sh)
- D99_stop_all.sh 스크립트를 실행하면 모든 서비스를 종료합니다.
- X21_unseal_vault.sh 스크립트는 볼트 서버를 봉인할 때 사용하는 스크립트입니다. (보안키를 감추기 위해 비상시 사용)

### 서비스 실행 스크립트 실행 순서
```bash
# 00. 네트워크 생성
./00_start_network.sh

# 05. 인증서 생성
# 05_0000. 볼트 서버 인증서와 접속용 클라이언트 인증서 생성
./05_0000_generate_vault_certs.sh
# 05_0010. user db 서버 인증서와 접속용 클라이언트 인증서 생성
./05_0010_generate_user_db_certs.sh

# 10. 데이터베이스 실행
./10_start_db.sh

# 20. 볼트 서버 실행
./20_start_vault.sh

# 21. 볼트 서버 초기화 (볼트 unseal)
./21_unseal_vault.sh

# 22. 볼트 엔진 설정
# 22_00_0000 데이터베이스 엔진 활성화
./22_00_0000_secrets_engine_database_enable.sh
# 22_10_0000 approle 엔진 활성화
./22_10_0000_auth_engine.approle_enable.sh

# 23. 볼트 데이터베이스 설정
# 23_0000. user db 설정
./23_0000_vault_user_db_config.sh

# 25. 앱롤 시크릿 생성
# 25_0000. user db 앱롤 시크릿 생성
./25_0000_vault_publish_user_db_approle_secret.sh

# 30. 모니터링 도구 실행
./30_start_monitoring.sh

# 40. 서비스 실행
./40_start_services_latest.sh # 개발 버전 이미지를 쓸 때는 ./40_start_services_develop.sh
```
