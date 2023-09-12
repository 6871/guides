#!/usr/bin/env bash
function test_base64_pad {
  local input="${1}"
  local expected="${2}"
  local exit_code="${3:?}"
  local result

  result="$(echo "${input}" | base64_pad4)"
  if [ "${result}" != "${expected}" ]; then
    printf 'ERROR: input="%s" expected="%s" result="%s" exit_code="%s"\n' \
        "${input}" "${expected}" "${result}" "${exit_code}" >&2
    exit "${exit_code:?}"
  fi

  printf 'OK: input="%s" expected="%s" result="%s"\n' \
      "${input}" "${expected}" "${result}" >&2
}

function main {
  local test_target
  test_target="$(dirname "$0")/../bash/auth.sh"
  printf 'test_target=%s\n' "${test_target:?}" >&2
  # shellcheck disable=SC1090
  source "${test_target:?}"
  test_base64_pad "" "" 1
  test_base64_pad "a" "a===" 2
  test_base64_pad "aa" "aa==" 3
  test_base64_pad "aaa" "aaa=" 4
  test_base64_pad "aaaa" "aaaa" 5
  test_base64_pad "aaaaa" "aaaaa===" 6
  printf 'OK: all tests passed\n' >&2
}

main "$@"
