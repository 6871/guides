# Authentication

How to get, view and validate authentication tokens from a local Red Hat
Single Sign-On server using the command line.

The following configuration files are used:

| File                                  | Description                                                                                                          |
|---------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| [`compose.yaml`](rh-sso/compose.yaml) | Docker Compose file to run a Red Hat Single Sign-On server                                                           |
| [`auth.sh`](bash/auth.sh)             | Functions to get, view and validate authentication server tokens<br>⚠️ JSON functions need `python3` to be installed |

# Setup Steps

1. Identity or set up a Red Hat developer account:

    * https://developers.redhat.com

2. Login to `registry.redhat.io`:

    ```bash
    # Requires account at https://developers.redhat.com
    docker login registry.redhat.io
    ```

3. Start the docker compose services:

    ```bash 
    docker compose --file rh-sso/compose.yaml up --detach \
    && docker compose --file rh-sso/compose.yaml logs --follow
    ```
    
    ```bash
    # To remove the service containers and volumes
    docker compose --file rh-sso/compose.yaml down --volumes
    ```

4. Verify the Red Hat SSO service is running on the local host:

    Ideally use a domain you control that resolves to 127.0.0.1; e.g.:

      * http://rh-sso.local.6871.uk:8080
    
    Localhost can be used, but can cause problems in some use cases:

      * http://localhost:8080

5. Install the functions from script [`auth.sh`](bash/auth.sh):

    ```bash
    # Add functions to current shell
    source ./bash/auth.sh
    ```

6. Set the environment variables used by [`auth.sh`](bash/auth.sh) functions
    to connect to the authentication server:

    ```bash
    # Ideally use a domain you control that resolves to 127.0.0.1; localhost
    # can be used, but can cause problems in some use cases
    AUTH_HOST='http://rh-sso.local.6871.uk:8080'
    AUTH_REALM='master'
    AUTH_USERNAME='admin'
    AUTH_PASSWORD='admin'
    AUTH_VENDOR='rh-sso'
    ```
   
    ```bash
    # Client ID is required for the primary realm; not all realms need it 
    AUTH_CLIENT_ID='admin-cli'
    ```

7. Use the [`auth.sh`](bash/auth.sh) functions to get, view and verify
    authentication tokens:

    ```bash
    # Get and view an authentication token
    auth_login
    auth_login | json_format
   
    # Get an authentication token and extract the access token part
    auth_login | json_get_access_token
   
    # Get an authentication token, extract the access token part and decode it
    auth_login | json_get_access_token | auth_decode_access_token
   
    # Get an authentication token, extract the access token part and verify it
    auth_login | json_get_access_token | auth_verify
    auth_login | json_get_access_token | auth_verify | json_format
    
    # STDERR can be suppressed; e.g.:
    (auth_login | json_get_access_token | auth_verify | json_format) 2>/dev/null
    ```
    
    Example output:

    ```
    % auth_login | json_get_access_token | auth_decode_access_token             
    login_url:
    http://rh-sso.local.6871.uk:8080/auth/realms/master/protocol/openid-connect/token
    --- JWT Header ---------------------------------------------
    {
        "alg": "RS256",
        "typ": "JWT",
        "kid": "etzQWQ9xmIGoaCR8xdEGMkHX2w8AcvdkKYajZo6ByLE"
    }
    --- JWT Payload --------------------------------------------
    {
        "exp": 1694557222,
        "iat": 1694557162,
        "jti": "94ab3d21-b160-4b92-bcdd-c1e7a4e07549",
        "iss": "http://rh-sso.local.6871.uk:8080/auth/realms/master",
        "sub": "850e9ae0-be6b-4772-b303-6469d954c335",
        "typ": "Bearer",
        "azp": "admin-cli",
        "session_state": "fa6a06a2-311e-4aaf-84fe-142a0dec245a",
        "acr": "1",
        "scope": "email profile",
        "sid": "fa6a06a2-311e-4aaf-84fe-142a0dec245a",
        "email_verified": false,
        "preferred_username": "admin"
    }
    --- JWT Signature ------------------------------------------
    AGTBhhq8q8vPUFmebaa0a_cyqQHMzDG5xvuTjshWj8i8UzeVY9jVsjvIg6a1KIea2liDxvYlFPQgFhUabRBhj6HqazovmpcLLAJCPAaFXM5ewwb-HP9ZeHKZT9cJBuAJobFzyMH-9cFwk7HKZ3v9BASjp_ctz-VO7zOGKO5TRqYi1FWCI-1qeTHGKfBnm0jBy_wXn4JKKiKmEQtZpDLc_zVzFtV8mk03-iT31qBJEm6cr1u3QvEod7cEZ_91wk4Ids_g97k32MRjnj9eGOfn__Je5tVyoAw6hVGmvWRXVLKHPTwxyMRyuY1kf4jmF-XgaEioREILgNp-TkH3lc_RGg
    ------------------------------------------------------------
    %
    ```

# Standalone Operation

Arbitrary token strings can be decoded as follows:

```bash
# Add functions to current shell
source ./bash/auth.sh
```

```bash
echo "${JWT_TOKEN:?}" | auth_decode_access_token
```

```bash
echo "${AUTH_TOKEN:?}" | json_get_access_token | auth_decode_access_token
```
