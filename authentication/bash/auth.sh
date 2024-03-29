#!/usr/bin/env bash
# A collection of functions to obtain, view and verify authentication tokens.
# Functions with prefix json_ require python3 to work.
# 1: Source this script with:
#     source ./auth.sh
# 2: Set the following mandatory environment variables for your host:
#     AUTH_HOST='https://example.com'
#     AUTH_VENDOR='keycloak'  # keycloak or rh-sso
#     AUTH_REALM='master'     # master requires AUTH_CLIENT_ID='admin-cli'
#     AUTH_USERNAME='admin'
#     AUTH_PASSWORD='...'
# 3: Optionally set the following environment variables:
#     AUTH_SCOPE='openid'  # may be required with AUTH_VENDOR='keycloak'
#     AUTH_ALLOW_INSECURE_HTTPS='true'
#     AUTH_CLIENT_ID='admin-cli'
#     AUTH_CLIENT_SECRET='...'
#     AUTH_CURL_VERBOSE='true'
# 4: To get an OIDC token, extract access_token (JWT), then decode it:
#     auth_login | json_get_access_token | auth_decode_jwt
# 5: To get an OIDC token, extract access_token (JWT), then verify it:
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
  local line
  while IFS= read -r line || [ -n "${line}" ]; do
    str_in="${str_in}${line}"$'\n'
  done
  local code='import json,sys;print(json.load(sys.stdin)["access_token"])'
  echo -n "${str_in}" | python3 -c "${code:?}"
}

# Read JSON input on STDIN and pretty-print it to STDOUT using Python.
function json_format {
  local str_in
  local line
  while IFS= read -r line || [ -n "${line}" ]; do
    str_in="${str_in}${line}"$'\n'
  done
  echo -n "${str_in%$'\n'}" | python3 -m json.tool
}

# Determine the host URL and print it to STDOUT (or return error).
function auth_base_url {
  local realm_prefix

  if [[ "${AUTH_VENDOR}" == 'rh-sso' ]]; then
    realm_prefix='/auth'
  elif [[ "${AUTH_VENDOR}" == 'keycloak' ]]; then
    realm_prefix=''
  else
    printf 'Error: AUTH_VENDOR="%s" is not valid; use one of: %s\n' \
        "${AUTH_VENDOR}" '{ rh-sso | keycloak }'
    return 1
  fi

  printf '%s%s/realms/%s/protocol/openid-connect' \
      "${AUTH_HOST:?}" "${realm_prefix}" "${AUTH_REALM:?}"
}

# Login to AUTH_HOST and output OIDC token to STDOUT.
function auth_login {
  local login_url
  login_url="$(auth_base_url)/token"
  printf 'login_url:\n%s\n' "${login_url:?}" >&2

  curl_arguments=()

  if [[ "${AUTH_CURL_VERBOSE}" == "true" ]]; then
    curl_arguments+=('--verbose')
  fi

  if [[ "${AUTH_ALLOW_INSECURE_HTTPS}" == "true" ]]; then
    curl_arguments+=('--insecure')
  fi

  curl_arguments+=(
    '--request' 'POST'
    '--silent'
    '--show-error'
    '--fail-with-body'
  )

  if [ -v AUTH_CLIENT_ID ]; then
    curl_arguments+=(--data-urlencode "client_id=${AUTH_CLIENT_ID}")
  fi

  # e.g. keycloak admin calls to master realm require scope=openid
  if [ -v AUTH_SCOPE ]; then
    curl_arguments+=(--data-urlencode "scope=${AUTH_SCOPE}")
  else
    if [[ "${AUTH_VENDOR}" == 'keycloak' ]]; then
      printf 'Warning: keycloak login token obtained without' >&2
      printf ' setting AUTH_SCOPE=openid may cause 403 errors in' >&2
      printf ' subsequent calls\n' >&2
    fi
  fi

  if [ -v AUTH_CLIENT_SECRET ]; then
    curl_arguments+=(--data-urlencode "client_secret=${AUTH_CLIENT_SECRET}")
  fi

  curl_arguments+=(
    --data "grant_type=password" \
    --data-urlencode "username=${AUTH_USERNAME}"
    --data-urlencode "password=${AUTH_PASSWORD}"
    "${login_url:?}"
  )

  curl "${curl_arguments[@]}"
}

# Read JWT access token from STDIN and verify it with AUTH_HOST.
function auth_verify {
  local str_in
  local line
  while IFS= read -r line || [ -n "${line}" ]; do
    str_in="${str_in}${line}"$'\n'
  done

  local verify_url
  verify_url="$(auth_base_url)/userinfo"
  printf 'verify_url:\n%s\n' "${verify_url}" >&2

  local auth_header="Authorization: Bearer ${str_in}"
  printf 'auth_header:\n%s\n' "${auth_header}" >&2

  curl_arguments=()

  if [[ "${AUTH_CURL_VERBOSE}" == "true" ]]; then
    curl_arguments+=('--verbose')
  fi

  if [[ "${AUTH_ALLOW_INSECURE_HTTPS}" == "true" ]]; then
    curl_arguments+=('--insecure')
  fi

  curl_arguments+=(
    --request POST
    --silent
    --show-error
    --fail-with-body
    --header "${auth_header:?}"
    "${verify_url:?}"
  )

  curl "${curl_arguments[@]}"
}

# Read JWT from STDIN, print decoded JWT to STDOUT.
function auth_decode_jwt {
  local str_in
  read -r str_in
  echo '--- JWT Header ---------------------------------------------'
  echo "${str_in}" | cut -d '.' -f1 | base64_pad4 | base64 --decode | json_format
  echo '--- JWT Payload --------------------------------------------'
  echo "${str_in}" | cut -d '.' -f2 | base64_pad4 | base64 --decode | json_format
  echo '--- JWT Signature ------------------------------------------'
  echo "${str_in}" | cut -d '.' -f3
  echo '------------------------------------------------------------'
}

# Function to unset empty environment variables.
function auth_unset_empty_env_vars {
  if [ -n "${AUTH_HOST+x}" ] && [ -z "${AUTH_HOST}" ]; then
    unset AUTH_HOST
  fi
  if [ -n "${AUTH_VENDOR+x}" ] && [ -z "${AUTH_VENDOR}" ]; then
    unset AUTH_VENDOR
  fi
  if [ -n "${AUTH_REALM+x}" ] && [ -z "${AUTH_REALM}" ]; then
    unset AUTH_REALM
  fi
  if [ -n "${AUTH_USERNAME+x}" ] && [ -z "${AUTH_USERNAME}" ]; then
    unset AUTH_USERNAME
  fi
  if [ -n "${AUTH_PASSWORD+x}" ] && [ -z "${AUTH_PASSWORD}" ]; then
    unset AUTH_PASSWORD
  fi
  if [ -n "${AUTH_CLIENT_ID+x}" ] && [ -z "${AUTH_CLIENT_ID}" ]; then
    unset AUTH_CLIENT_ID
  fi
  if [ -n "${AUTH_CLIENT_SECRET+x}" ] && [ -z "${AUTH_CLIENT_SECRET}" ]; then
    unset AUTH_CLIENT_SECRET
  fi
  if [ -n "${AUTH_SCOPE+x}" ] && [ -z "${AUTH_SCOPE}" ]; then
    unset AUTH_SCOPE
  fi
  if [ -n "${AUTH_ALLOW_INSECURE_HTTPS+x}" ] \
      && [ -z "${AUTH_ALLOW_INSECURE_HTTPS}" ]; then
    unset AUTH_ALLOW_INSECURE_HTTPS
  fi
  if [ -n "${AUTH_CURL_VERBOSE+x}" ] && [ -z "${AUTH_CURL_VERBOSE}" ]; then
    unset AUTH_CURL_VERBOSE
  fi
}

# Function to set environment variables used by login and verify functions.
function auth_set_env_vars {
  printf 'Enter server details (empty value unsets variable):\n'
  printf 'AUTH_HOST (e.g. "https://example.com") : ' && read -r AUTH_HOST
  printf 'AUTH_VENDOR  { "keycloak" | "rh-sso" } : ' && read -r AUTH_VENDOR
  printf 'AUTH_REALM             (e.g. "master") : ' && read -r AUTH_REALM
  printf 'AUTH_USERNAME           (e.g. "admin") : ' && read -r AUTH_USERNAME
  printf 'AUTH_PASSWORD                          : '
  read -r -s AUTH_PASSWORD && echo
  printf 'AUTH_CLIENT_ID      (e.g. "admin-cli") : ' && read -r AUTH_CLIENT_ID
  printf 'AUTH_CLIENT_SECRET                     : '
  read -r -s AUTH_CLIENT_SECRET && echo
  printf 'AUTH_SCOPE (e.g. "openid" on Keycloak) : ' && read -r AUTH_SCOPE
  printf 'AUTH_ALLOW_INSECURE_HTTPS [{ "true" }] : '
  read -r AUTH_ALLOW_INSECURE_HTTPS
  printf 'AUTH_CURL_VERBOSE         [{ "true" }] : '
  read -r AUTH_CURL_VERBOSE
  auth_unset_empty_env_vars
}
