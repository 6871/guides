# SSH

## Create SSH Key Pair

1. Create SSH key passphrase:

    ```bash
    SSH_KEY_PASSPHRASE="$(openssl rand -base64 48)"
    echo -n "${SSH_KEY_PASSPHRASE:?}" | pbcopy
    SSH_KEY_NAME='user@host@YYYY-MM-DD'
    ```

2. Save `SSH_KEY_PASSPHRASE` value securely (e.g.  macOS "Keychain Access" App)

3. Set SSH key name:

    ```bash
    SSH_KEY_NAME='user@host@YYYY-MM-DD'
    ```

4. Create SSH key pair:

    ```bash
    ssh-keygen \
      -t ed25519 \
      -C "${SSH_KEY_NAME:?}" \
      -f "${HOME:?}/.ssh/${SSH_KEY_NAME:?}" \
      -N "${SSH_KEY_PASSPHRASE:?}"
    ```
