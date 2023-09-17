#!/usr/bin/env bash
# Generate environment variable values for compose.yaml file; to use:
# ./create_env_file.sh > .env
printf 'RH_SSO_DB_USER=rh-sso-db-user\n'
printf 'RH_SSO_DB_USER_PASSWORD=%s\n' "$(openssl rand -base64 48)"
printf 'RH_SSO_ADMIN_USER=admin\n'
printf 'RH_SSO_ADMIN_USER_PASSWORD=%s\n' "$(openssl rand -base64 48)"
