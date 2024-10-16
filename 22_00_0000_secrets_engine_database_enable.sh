#!/bin/bash

(
  ENGINE_TYPE="secrets"
  ENGINE_NAME="database"
  VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' ./credentials/vault/init/admin-policy.json)

  ./22_BASE_00_enable_engine.sh \
    --engine_type="$ENGINE_TYPE" \
    --engine_name="$ENGINE_NAME" \
    --vault_policy_token="$VAULT_POLICY_TOKEN"
)