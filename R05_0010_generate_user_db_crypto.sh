#!/bin/bash

# ==============================================
# Script Name:	Generate User DB Crypto
# Description:	This script generates the User DB server and client crypto.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  SERVICE_NAME="${USER_DB_SERVICE_NAME}"
  SERVER_CRYPTO_PATH="${USER_DB_SERVER_CRYPTO_PATH}"
  CLIENT_CRYPTO_PATH="${USER_DB_CLIENT_CRYPTO_PATH}"
  CA_CRYPTO_PATH="${USER_DB_CA_CRYPTO_PATH}"
  SERVER_KEY_CNF_FILE_PATH="${USER_DB_SERVER_KEY_CNF_FILE_PATH}"
  CLIENT_KEY_CNF_FILE_PATH="${USER_DB_CLIENT_KEY_CNF_FILE_PATH}"
  SERVER_PRIVATE_KEY_PATH="${USER_DB_SERVER_PRIVATE_KEY_PATH}"
  SERVER_CSR_FILE_PATH="${USER_DB_SERVER_CSR_FILE_PATH}"
  SERVER_CERT_FILE_PATH="${USER_DB_SERVER_CERT_FILE_PATH}"
  CLIENT_PRIVATE_KEY_PATH="${USER_DB_CLIENT_PRIVATE_KEY_PATH}"
  CLIENT_CSR_FILE_PATH="${USER_DB_CLIENT_CSR_FILE_PATH}"
  CLIENT_CERT_FILE_PATH="${USER_DB_CLIENT_CERT_FILE_PATH}"
  SERVER_PUBLIC_CERT_PATH="${USER_DB_SERVER_PUBLIC_CERT_PATH}"
  CLIENT_PUBLIC_CERT_PATH="${USER_DB_CLIENT_PUBLIC_CERT_PATH}"

  log d "Create directories if they don't exist for User DB Crypto..."
  try mkdir -p "${SERVER_CRYPTO_PATH}"
  try mkdir -p "${CLIENT_CRYPTO_PATH}"
  try mkdir -p "${CA_CRYPTO_PATH}"
  try mkdir -p "${PUBLIC_CERT_PATH}"

  SIGNING_SCRIPT_CMD="./CMN_ca_signing.sh --ca_key_path=${INTER_CA2_PRIVATE_KEY_PATH} --ca_cert_path=${INTER_CA2_CERT_FILE_PATH}"

  ./R05_BASE_generate_service_crypto.sh --service_name="${SERVICE_NAME}" \
                  --server_key_cnf_file_path="${SERVER_KEY_CNF_FILE_PATH}" \
                  --client_key_cnf_file_path="${CLIENT_KEY_CNF_FILE_PATH}" \
                  --server_private_key_path="${SERVER_PRIVATE_KEY_PATH}" \
                  --client_private_key_path="${CLIENT_PRIVATE_KEY_PATH}" \
                  --server_csr_file_path="${SERVER_CSR_FILE_PATH}" \
                  --client_csr_file_path="${CLIENT_CSR_FILE_PATH}" \
                  --server_cert_file_path="${SERVER_CERT_FILE_PATH}" \
                  --client_cert_file_path="${CLIENT_CERT_FILE_PATH}" \
                  --server_public_cert_path="${SERVER_PUBLIC_CERT_PATH}" \
                  --client_public_cert_path="${CLIENT_PUBLIC_CERT_PATH}" \
                  --signing_script_cmd="${SIGNING_SCRIPT_CMD}"
  exit_on_error "Failed to generate User DB Crypto."
)