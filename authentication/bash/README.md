# CLI Authentication Functions

CLI functions to get, view and verify authentication tokens.

* [Functions](#functions)
* [Installing](#installing)
* [Decoding & Printing JWT Strings](#decoding--printing-jwt-strings)
* [Environment Variables](#environment-variables)
* [Get & Verify Server Tokens](#get--verify-server-tokens)

# Functions

| Function                            | Description                                                                                           |
|-------------------------------------|-------------------------------------------------------------------------------------------------------|
| `auth_set_env_vars`                 | Interactive prompts to set required environment variables                                             |
| `auth_login`<sup>1</sup>            | Log in to `AUTH_HOST` as `AUTH_USERNAME` with `AUTH_PASSWORD` and print acquired OIDC token to STDOUT |
| `json_get_access_token`<sup>2</sup> | Read an OIDC token JSON string from STDIN, print `access_token` field JWT to STDOUT                   |
| `auth_decode_jwt`                   | Read a JWT string from STDIN, print decoded JWT to STDOUT                                             |
| `auth_verify`<sup>1</sup>           | Read a JWT string from STDIN and verify it with `AUTH_HOST`                                           |
| `json_format`<sup>2</sup>           | Read a JSON string from STDIN and pretty-print it to STDOUT                                           | 

> <sup>1</sup>️ see section [Environment Variables](#environment-variables)

> <sup>2</sup>️ `json_` functions require a `python3` install
 
# Installing

Source script [auth.sh](auth.sh) to add authentication functions to the
current shell; e.g.:

```bash
# Add functions to current shell
source ./auth.sh
```

# Decoding & Printing JWT Strings

Function `auth_decode_jwt` can be used to decode an arbitrary JWT token; e.g.:

```bash
# Example from https://en.wikipedia.org/wiki/JSON_Web_Token
JWT_TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'\
'eyJsb2dnZWRJbkFzIjoiYWRtaW4iLCJpYXQiOjE0MjI3Nzk2Mzh9.'\
'gzSraSYS8EXBxLN_oWnFSRgCzcmJmMjLiuyu5CSpyHI'

echo "${JWT_TOKEN:?}" | auth_decode_jwt
```

```
--- JWT Header ---------------------------------------------
{
    "alg": "HS256",
    "typ": "JWT"
}
--- JWT Payload --------------------------------------------
{
    "loggedInAs": "admin",
    "iat": 1422779638
}
--- JWT Signature ------------------------------------------
gzSraSYS8EXBxLN_oWnFSRgCzcmJmMjLiuyu5CSpyHI
------------------------------------------------------------
```

# Environment Variables

Functions `auth_login` and `auth_verify` use the following environment
variables to connect to an authentication server:

| Variable                    | Description                                          |
|-----------------------------|------------------------------------------------------|
| `AUTH_HOST`                 | e.g. "https://example.com"                           |
| `AUTH_VENDOR`               | "keycloak" or "rh-sso"                               | 
| `AUTH_REALM`                | e.g. typically "master" on a new install             | 
| `AUTH_USERNAME`             | typically "admin" on a new install                   |
| `AUTH_PASSWORD`             | password for AUTH_USERNAME                           |
| `AUTH_CLIENT_ID`            | e.g. "admin-cli" for admin access on a new install   |
| `AUTH_CLIENT_SECRET`        | server-side configuration for some use cases         |
| `AUTH_SCOPE`                | e.g. may need "openid" if AUTH_VENDOR=keycloak       |
| `AUTH_ALLOW_INSECURE_HTTPS` | set to "true" for host with non-CA HTTPS certificate |

# Get & Verify Server Tokens

To perform authentication server login and verification calls:

1. Set [Environment Variables](#environment-variables) for the target server:

    ```bash
    # e.g. Keycloak 22.0.3 host in initial state (only default realm)
    AUTH_HOST='https://keycloak.local.6871.uk'
    AUTH_VENDOR='keycloak'
    AUTH_REALM='master'
    AUTH_USERNAME='admin'
    read -r -s AUTH_PASSWORD
    AUTH_CLIENT_ID='admin-cli'
    AUTH_SCOPE='openid'
    ```
    
    ```bash
    # e.g. Red Hat SSO 7.6-27 host in initial state (only default realm)
    AUTH_HOST='https://rh-sso.local.6871.uk'
    AUTH_VENDOR='rh-sso'
    AUTH_REALM='master'
    AUTH_USERNAME='admin'
    read -r -s AUTH_PASSWORD
    AUTH_CLIENT_ID='admin-cli'
    ```

2. Use the [`auth.sh`](auth.sh) functions to get, view and verify
    authentication tokens:

    ```bash
    # Get and view an authentication token
    auth_login
    auth_login | json_format
   
    # Get an authentication token and extract the access token part
    auth_login | json_get_access_token
   
    # Get an authentication token, extract the access token part and decode it
    auth_login | json_get_access_token | auth_decode_jwt
   
    # Get an authentication token, extract the access token part and verify it
    auth_login | json_get_access_token | auth_verify
    auth_login | json_get_access_token | auth_verify | json_format
    
    # STDERR can be suppressed; e.g.:
    (auth_login | json_get_access_token | auth_verify | json_format) 2>/dev/null
    ```
