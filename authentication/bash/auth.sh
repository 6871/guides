#!/usr/bin/env bash
# Functions to obtain, process and verify JWT access tokens.
# JSON functions need python3 to be installed.
# 1: Source this script with:
#     source ./auth_cli.sh
# 2: Set the following mandatory environment variables for your host:
#     AUTH_HOST='https://example.com'
#     AUTH_REALM='master'
#     AUTH_USERNAME='admin'
#     AUTH_PASSWORD='admin'
# 3: Optionally set the following environment variables:
#     AUTH_CLIENT_ID='admin-cli'
#     AUTH_CLIENT_SECRET=''
# 4: To get an OIDC token, extract JWT access_token, then decode it:
#     auth_login | json_get_access_token | auth_decode_access_token
# 5: To get an OIDC token, extract JWT access_token, then verify it:
#     auth_login | json_get_access_token | auth_verify

# Read string from STDIN; if it's not a multiple of 4 chars, pad it with '='
# until it is; print result to STDOUT.
function base64_pad4 {
  local pad_size=4
  local str_in
  read -r str_in
  printf '%s' "${str_in}"
  if ((${#str_in} % "${pad_size:?}" != 0)); then
    printf '=%.0s' $(seq "$((${pad_size:?} - ${#str_in} % ${pad_size:?}))")
  fi
}

# Read JSON from STDIN and print the value of the access_token key to STDOUT.
function json_get_access_token {
  local str_in
  read -r str_in
  local code='import json,sys;print(json.load(sys.stdin)["access_token"])'
  echo -n "${str_in}" | python3 -c "${code:?}"
}

# Read JSON input on STDIN and pretty-print it to STDOUT using Python.
function json_format {
  local str_in
  read -r str_in
  echo -n "${str_in}" | python3 -m json.tool
}

# Login to AUTH_HOST and output OIDC token to STDOUT.
function auth_login {
  local realm_prefix="${1:-/auth}"  # "" for Keycloak, /auth for Red Hat SSO
  local login_url="${AUTH_HOST:?}${realm_prefix}/realms/${AUTH_REALM:?}/protocol/openid-connect/token"
  printf 'login_url:\n%s\n' "${login_url:?}" >&2
  curl \
    --request POST \
    --silent \
    --show-error \
    --fail-with-body \
    --data-urlencode "client_id=${AUTH_CLIENT_ID}" \
    --data-urlencode "client_secret=${AUTH_CLIENT_SECRET}" \
    --data-urlencode "username=${AUTH_USERNAME:?}" \
    --data-urlencode "password=${AUTH_PASSWORD:?}" \
    --data "grant_type=password" \
    "${login_url:?}"
}

# Read JWT access token from STDIN and verify it against AUTH_HOST.
function auth_verify {
  local realm_prefix="${1:-/auth}"  # "" for Keycloak, /auth for Red Hat SSO
  local verify_url="${AUTH_HOST:?}${realm_prefix}/realms/${AUTH_REALM:?}/protocol/openid-connect/userinfo"
  printf 'verify_url:\n%s\n' "${verify_url}" >&2
  local str_in
  read -r str_in
  local auth_header="Authorization: Bearer ${str_in}"
  printf 'auth_header:\n%s\n' "${auth_header}" >&2
  curl \
    --request POST \
    --silent \
    --show-error \
    --fail-with-body \
    --header "${auth_header:?}" \
    "${verify_url:?}"
}

# Read JWT access token from STDIN and decode it to STDOUT.
function auth_decode_access_token {
  local str_in
  read -r str_in
  printf '--- JWT Header ---------------------------------------------\n'
  echo "${str_in}" | cut -d '.' -f1 | base64_pad4 | base64 --decode | json_format
  printf '--- JWT Payload --------------------------------------------\n'
  echo "${str_in}" | cut -d '.' -f2 | base64_pad4 | base64 --decode | json_format
  printf '--- JWT Signature ------------------------------------------\n'
  echo "${str_in}" | cut -d '.' -f3
  printf '------------------------------------------------------------\n'
}
