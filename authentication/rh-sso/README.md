# Red Hat Single Sign-On Example

Docker Compose services to run a local Red Hat Single Sign-On server and
execute CLI functions to get, view and validate authentication tokens.

# Configuration Files

| File                               | Description                                                                          |
|------------------------------------|--------------------------------------------------------------------------------------|
| [compose.yaml](compose.yaml)       | Docker Compose file to run a Red Hat Single Sign-On server and some example commands |
| [../bash/auth.sh](../bash/auth.sh) | Functions to get, view and validate authentication server tokens                     |

The [compose.yaml](compose.yaml) file runs the following services:

| Service       | Description                                                                |
|---------------|----------------------------------------------------------------------------|
| rh-sso        | Red Hat Single Sign-On server                                              |
| rh-sso-db     | Database for Red Hat Single Sign-On server                                 |
| auth-cli-demo | Run-once container showing how to use [auth.sh](../bash/auth.sh) functions |

For the latest Red Hat Single Sign-On image, see:

* https://catalog.redhat.com/software/containers/rh-sso-7/sso76-openshift-rhel8/629651e2cddbbde600c0a2ec

# How To Run

1. Identity or set up a Red Hat developer account:

    * https://developers.redhat.com

2. Login to `registry.redhat.io`:

    ```bash
    # Requires account at https://developers.redhat.com
    docker login registry.redhat.io
    ```

3. Create a `.env` file to set the usernames and passwords required by the
   [compose.yaml](compose.yaml) services; this can be done by running script
   [create_env_file.sh](create_env_file.sh):

    ```bash
    ./create_env_file.sh > .env
    ```

4. Start the docker compose services:

    ```bash 
    docker compose up --detach \
    && docker compose logs --follow
    ```
    
    ```bash
    # To remove the service containers and volumes
    docker compose down --volumes
    ```

5. Verify the Red Hat SSO service is running on the local host:

    Ideally use a domain you control that resolves to 127.0.0.1; e.g.:

      * http://rh-sso.local.6871.uk:8080
    
    Localhost can be used, but can cause problems in some use cases:

      * http://localhost:8080

6. Install authentication functions from [auth.sh](../bash/auth.sh):

    ```bash
    # Add functions to current shell
    source ../bash/auth.sh
    ```

7. Set the environment variables for the functions:

    ```bash
    # Ideally use a domain you control that resolves to 127.0.0.1; localhost
    # can be used, but can cause problems in some use cases
    AUTH_HOST='http://rh-sso.local.6871.uk:8080'
    AUTH_VENDOR='rh-sso'
    AUTH_REALM='master'
    AUTH_USERNAME="$(source .env && echo -n "${RH_SSO_ADMIN_USER:?}")"
    AUTH_PASSWORD="$(source .env && echo -n "${RH_SSO_ADMIN_USER_PASSWORD:?}")"
    ```
   
    ```bash
    # Client ID is required for the primary realm; not all realms need it 
    AUTH_CLIENT_ID='admin-cli'
    ```

8. Use the [auth.sh](../bash/auth.sh) functions to get, view and verify authentication
    tokens:

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
    
    Example output:

    ```
    % auth_login | json_get_access_token | auth_decode_jwt
    login_url:
    http://rh-sso.local.6871.uk:8080/auth/realms/master/protocol/openid-connect/token
    --- JWT Header ---------------------------------------------
    {
        "alg": "RS256",
        "typ": "JWT",
        "kid": "R7vRC7hph6dWO53hClsrAV9sQi7hDIqqYqPB5f5J3Ac"
    }
    --- JWT Payload --------------------------------------------
    {
        "exp": 1695242994,
        "iat": 1695242934,
        "jti": "00e91716-cf8b-48dd-876c-e2e5826508dc",
        "iss": "http://rh-sso.local.6871.uk:8080/auth/realms/master",
        "sub": "965ce79b-699e-4a5c-b320-54a1f0743503",
        "typ": "Bearer",
        "azp": "admin-cli",
        "session_state": "cdbda5b3-ac60-4732-9a42-74e0b93b71ad",
        "acr": "1",
        "scope": "email profile",
        "sid": "cdbda5b3-ac60-4732-9a42-74e0b93b71ad",
        "email_verified": false,
        "preferred_username": "admin"
    }
    --- JWT Signature ------------------------------------------
    ru7Tarh5Tzyymw0rTLOmZ0VJ3BYOD-jslycZ6-FooVha2caCsy0WkHKmyDa-vU-SU_U0oQi4USHqAo-5NXGVRV2eN6TxJ5aopi-uMArDOv6X17zTt3xYZevcKcaEMD569XUJtDtsLVEnN1ZGIMeeYn5lFaRYFkseIerznnRcVJBQYfVbqNZPkU_KgG9hLZUfBMmWgr1Gr-pONzo9Fj5PnQP3f0JQFk9vJrUjGhwXIS4OZ7G7JgIQdcA0SJT4saoHc1GF3B0B5tnLe5s_jYteKnhAAIK-s6dz5C5lOSNoGVCgq_ps89s-Cq_Rc144TnbAtk60DpUJ6XCSNmSJ9ABHYA
    ------------------------------------------------------------
    %
    ```
