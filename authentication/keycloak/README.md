# Keycloak Example

Docker Compose services to run a local Keycloak server and execute CLI
functions to get, view and validate authentication tokens.

# Configuration Files

| File                               | Description                                                            |
|------------------------------------|------------------------------------------------------------------------|
| [compose.yaml](compose.yaml)       | Docker Compose file to run a Keycloak server and some example commands |
| [../bash/auth.sh](../bash/auth.sh) | Functions to get, view and validate authentication server tokens       |

The [compose.yaml](compose.yaml) file runs the following services:

| Service             | Description                                                                   |
|---------------------|-------------------------------------------------------------------------------|
| create-https-config | Run-once container to create a HTTPS certificate and private key for Keycloak |
| keycloak            | Keycloak server                                                               |
| keycloak-db         | Database for Keycloak server                                                  |
| auth-cli-demo       | Run-once container showing how to use [auth.sh](../bash/auth.sh) functions    |

For the latest Keycloak image, see:

* https://quay.io/repository/keycloak/keycloak?tab=tags

# How To Run

1. Create a `.env` file to set the usernames and passwords required by the
    [compose.yaml](compose.yaml) services; this can be done by running script
    [create_env_file.sh](create_env_file.sh):

    ```bash
    ./create_env_file.sh > .env
    ```

2. Start the docker compose services:

    ```bash 
    docker compose up --detach \
    && docker compose logs --follow
    ```
    
    ```bash
    # To remove the service containers and volumes
    docker compose down --volumes
    ```

3. Verify the Keycloak service is running on the local host:

    Ideally use a domain you control that resolves to 127.0.0.1; e.g.:

      * http://keycloak.local.6871.uk:8080
    
    Localhost can be used, but can cause problems in some use cases:

      * http://localhost:8080

4. Install authentication functions from [auth.sh](../bash/auth.sh):

    ```bash
    # Add functions to current shell
    source ../bash/auth.sh
    ```

5. Set the environment variables for the functions:

    ```bash
    # Ideally use a domain you control that resolves to 127.0.0.1; localhost
    # can be used, but can cause problems in some use cases
    AUTH_HOST='https://keycloak.local.6871.uk'
    AUTH_VENDOR='keycloak'
    AUTH_REALM='master'
    AUTH_USERNAME="$(source .env && echo -n "${KEYCLOAK_ADMIN_USER:?}")"
    AUTH_PASSWORD="$(source .env && echo -n "${KEYCLOAK_ADMIN_USER_PASSWORD:?}")"
    AUTH_SCOPE='openid'
    AUTH_ALLOW_INSECURE_HTTPS='true'
    ```
   
    ```bash
    # Client ID is required for the primary realm; not all realms need it 
    AUTH_CLIENT_ID='admin-cli'
    ```

6. Use the [auth.sh](../bash/auth.sh) functions to get, view and verify authentication
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
    https://keycloak.local.6871.uk/realms/master/protocol/openid-connect/token
    --- JWT Header ---------------------------------------------
    {
        "alg": "RS256",
        "typ": "JWT",
        "kid": "jA7HFG2pMzdFTs5Qsmnr8a9zuNmYKKPLHz1XHAfCm6A"
    }
    --- JWT Payload --------------------------------------------
    {
        "exp": 1695240950,
        "iat": 1695240890,
        "jti": "36f04644-d48a-487f-91e7-c47e8d03a84b",
        "iss": "https://keycloak.local.6871.uk/realms/master",
        "sub": "984d0865-9c5a-4a5f-a949-7fcaf1eb478e",
        "typ": "Bearer",
        "azp": "admin-cli",
        "session_state": "c5118176-1f11-44f4-890d-5c4618e43615",
        "acr": "1",
        "scope": "openid profile email",
        "sid": "c5118176-1f11-44f4-890d-5c4618e43615",
        "email_verified": false,
        "preferred_username": "admin"
    }
    --- JWT Signature ------------------------------------------
    PYzvsqo9mxi_yNvWYcip9dcMov7gv6weAU0-8oN1VRy2XWGdpKd-8WwFbZU05ZY8iKBre7Mh35hL2Iwf3k3apgCm_TEccR0VFUmlhI-eqJCoWVCGyWSw59rVfL6MUzXQb9dya6mEBWHydjSDbnNPvUw4HciB7nR9tp6tOia5jnKD3qnvMGi-g9C8xfwFhhooOtWEunQ25bleM7Nm13sSjzQ19h8nA4udGUdz6zan-Dg8NL4SB2UXH7kddkd6YsZomTXE17Bz38VmXBqxCJ9ENJahid_kz_UjTpYvq-JQOsmOWq1qIEB7W3Kd7GIMDbxoL-DV1p6bIAv66C8wWjlKQw
    ------------------------------------------------------------
    %
    ```
