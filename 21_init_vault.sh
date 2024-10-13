#!/bin/sh

(
  VAULT_CONTAINER_NAME="ats-vault"
  VAULT_CREDENTIAL_INIT_PATH="./credentials/vault/init"

  VAULT_KEY_SHARES=${VAULT_KEY_SHARES:-10}
  VAULT_KEY_THRESHOLD=${VAULT_KEY_THRESHOLD:-3}

  # Vault가 이미 초기화되었는지 확인
  docker exec $VAULT_CONTAINER_NAME vault status | grep "Initialized" | grep "true" && exit 0

  mkdir -p "${VAULT_CREDENTIAL_INIT_PATH}"

  # Vault 초기화 (10개의 키를 만들고, 최소 3개의 키가 있어야 봉인 해제 가능)
  docker exec $VAULT_CONTAINER_NAME vault operator init -key-shares=${VAULT_KEY_SHARES} -key-threshold=${VAULT_KEY_THRESHOLD} > "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt"

  # 생성된 Root Token 출력
  ROOT_TOKEN=$(grep 'Initial Root Token:' "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')

  # 루프를 사용하여 모든 Unseal 키를 저장 및 출력
  for i in $(seq 1 $VAULT_KEY_SHARES); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    echo -e "${GREEN}Unseal Key $i: $UNSEAL_KEY${NC}"
  done

  # Vault Unseal (최소 $VAULT_KEY_THRESHOLD개의 Unseal Key를 사용해 봉인 해제)
  for i in $(seq 1 $VAULT_KEY_THRESHOLD); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    docker exec $VAULT_CONTAINER_NAME vault operator unseal "$UNSEAL_KEY"
  done


  # Vault 로그인 (Root Token을 사용해 일시적으로 로그인)
  docker exec $VAULT_CONTAINER_NAME vault login "$ROOT_TOKEN"

  echo "Vault initialized, unsealed with 3 keys, and logged in with Root Token."

  # 정책 파일 적용 (database-policy.hcl)
  docker exec $VAULT_CONTAINER_NAME vault policy write approle-policy /vault/config/approle-policy.hcl
  docker exec $VAULT_CONTAINER_NAME vault policy write database-policy /vault/config/database-policy.hcl
  docker exec $VAULT_CONTAINER_NAME vault policy write admin-policy /vault/config/admin-policy.hcl

  # 정책 기반 토큰 생성 (Root Token 대신 사용할 정책 기반 토큰 생성, orphan 옵션은 루트 토큰이 폐기되어도 토큰이 기능하게 만든다.)
  docker exec $VAULT_CONTAINER_NAME vault token create -orphan -policy=approle-policy -format=json > "$VAULT_CREDENTIAL_INIT_PATH/approle-policy.json"
  docker exec $VAULT_CONTAINER_NAME vault token create -orphan -policy=database-policy -format=json > "$VAULT_CREDENTIAL_INIT_PATH/database-policy.json"
  docker exec $VAULT_CONTAINER_NAME vault token create -orphan -policy=admin-policy -format=json > "$VAULT_CREDENTIAL_INIT_PATH/admin-policy.json"

  echo "Policy-based tokens created. Token stored in ${VAULT_CREDENTIAL_INIT_PATH}/*-policy.json"

  # Root Token 폐기 (보안 강화)
  docker exec $VAULT_CONTAINER_NAME vault token revoke "$ROOT_TOKEN"
  echo "Root Token has been revoked for security."

  echo "Vault is now ready to use with policy-based tokens."

  # Unseal 키 분배 안내 메시지
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  echo -e "${YELLOW}[IMPORTANT] Unseal keys have been generated.${NC}"
  echo -e "${RED}Please manually distribute these keys among administrators and securely store them.${NC}"
  # 루프를 사용하여 모든 Unseal 키 출력
  for i in $(seq 1 $VAULT_KEY_SHARES); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    echo -e "${GREEN}Unseal Key $i: $UNSEAL_KEY${NC}"
  done
  echo -e "${YELLOW}Once the keys are securely distributed, manually delete the init-keys.txt file for security purposes.${NC}"
)