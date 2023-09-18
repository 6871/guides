#!/usr/bin/env bash
# Generate environment variable values for compose.yaml file; to use:
# ./create_env_file.sh > .env
printf 'KEYCLOAK_DB_USER=keycloak-db-user\n'
printf 'KEYCLOAK_DB_USER_PASSWORD=%s\n' "$(openssl rand -base64 48)"
printf 'KEYCLOAK_ADMIN_USER=admin\n'
printf 'KEYCLOAK_ADMIN_USER_PASSWORD=%s\n' "$(openssl rand -base64 48)"
