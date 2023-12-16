# GPG

* [Install GPGTools (macOS)](#install-gpgtools-macos)
    * [Download](#download)
    * [Verify SHA Checksum](#verify-sha-checksum)
    * [Verify GPG Signature (Using Docker)](#verify-gpg-signature-using-docker)
    * [Run Installer](#run-installer)
* [Key Management](#key-management)
    * [Creating Key Pairs](#creating-key-pairs)
    * [Listing Keys](#listing-keys)
    * [Exporting Keys](#exporting-keys)
    * [Importing Keys](#importing-keys)
* [Encryption & Decryption](#encryption--decryption)
    * [File Encryption](#file-encryption)
    * [File Decryption](#file-decryption)
* [Signing & Signature Verification](#signing--signature-verification)
    * [Files](#files)
        * [Signing A File](#signing-a-file)
        * [Verifying A Signed File](#verifying-a-signed-file)
    * [Clear Signing Messages](#clear-signing-messages)
        * [Creating](#creating)
        * [Verifying](#verifying)
* [Inspecting GPG Files](#inspecting-gpg-files)
* [References](#references)

# Install GPGTools (macOS)

Apple provide some notes on using GPG here:

* https://support.apple.com/en-us/HT201214

At the time of writing the above article references:

* https://gpgtools.org
* https://www.gnupg.org

## Download

Go to https://gpgtools.org and download:

* GPG installation file
* GPG installation GPG signature file

## Verify SHA Checksum

Verify the GPG download's SHA checksum matches the one reported at https://gpgtools.org; i.e. run:

```bash
shasum -a 256 ~/Downloads/GPG_Suite-2023.3.dmg
```

## Verify GPG Signature (Using Docker)

To run GPG in a Docker container to verify the GPG install file:

1. Identify GPG install and signature files, and their directory:

    ```bash
    # Adjust accordingly for your download:
    GPG_INSTALL_FILE='GPG_Suite-2023.3.dmg'
    GPG_INSTALL_FILE_SIG="${GPG_INSTALL_FILE:?}.sig"
    GPG_INSTALL_FILE_DIR="${HOME:?}/Downloads"
    ```

2. Run a temporary Docker container that mounts `GPG_INSTALL_FILE_DIR` to `/workdir` in the container:

    ```bash
    docker \
      run \
        --name gpg-check \
        --rm --tty --interactive \
        --mount "type=bind,source=${GPG_INSTALL_FILE_DIR:?},target=/workdir" \
        --env "GPG_INSTALL_FILE=${GPG_INSTALL_FILE:?}" \
        --env "GPG_INSTALL_FILE_SIG=${GPG_INSTALL_FILE_SIG:?}" \
        --entrypoint bash \
        --workdir /workdir \
        ubuntu:latest
    ```

3. Install `gpg` and `curl` in the above `gpg-check` container:

    ```bash
    apt update
    apt install --yes gpg curl
    ```

    ⚠️ The `gpg` install is only as trustworthy as the container image and `gpg` apt package  

4. Obtain the public key for `team@gpgtools.org`:

    ```bash
    # Assuming website is not compromised:
    curl 'https://gpgtools.org/GPGTools-00D026C4.asc' | gpg --import
    ```
    
    ℹ️ The public key could also be loaded from a public keyserver

5. Verify the imported public key:

    ```bash
    # To view imported key details:
    gpg --list-keys
    gpg --list-keys team@gpgtools.org
    gpg --fingerprint team@gpgtools.org
    gpg --check-sigs team@gpgtools.org
    
    # To view details on public key servers for comparison:
    gpg --keyserver pgp.mit.edu --fingerprint team@gpgtools.org
    gpg --keyserver certserver.pgp.com --fingerprint team@gpgtools.org
    ```

6. Verify the GPG install package:

    ```bash
    gpg --verify "${GPG_INSTALL_FILE_SIG:?}" "${GPG_INSTALL_FILE:?}"
    ```
    
    ⚠️ The above command will emit a warning; if you really trust the key,
    suppress the warning with one of the following methods:

    ```bash
    # Identify key's fingerprint using: gpg --list-keys team@gpgtools.org
    KEY_FINGERPRINT='85E38F69046B44C1EC9FB07B76D78F0500D026C4'
   
    # Tell GPG to trust the above key
    gpg --trusted-key "${KEY_FINGERPRINT:?}" --verify "${GPG_INSTALL_FILE_SIG:?}" "${GPG_INSTALL_FILE:?}"
    ```

    ```bash
    # Set the key's trust level using interactive prompts
    gpg --edit-key team@gpgtools.org
    ```

## Run Installer

Only run the GPG installer if the above verification steps are OK.

# Key Management

## Creating Key Pairs

> ⚠️ GitHub commit signing keys must be RSA >= 4096 bit

```bash
# Generate a passphrase; e.g.:
PASSPHRASE="$(openssl rand -base64 48)"
echo -n "${PASSPHRASE:?}" | pbcopy

# Prompts for settings
gpg --full-generate-key
```

## Listing Keys

```bash
# Public
gpg --list-keys
```

```bash
# Private
gpg --list-secret-keys --keyid-format=long
```

## Exporting Keys

```bash
# Note: `--armor` flag outputs text (not binary) format
EMAIL=''
PUBLIC_KEY_FILENAME="gpg_key_${EMAIL:?}.public"
PRIVATE_KEY_FILENAME="gpg_key_${EMAIL:?}.private"

# Public key
gpg --armor --export "${EMAIL:?}" > "${PUBLIC_KEY_FILENAME:?}"

# Export private key
gpg --armor --export-secret-keys "${EMAIL:?}" > "${PRIVATE_KEY_FILENAME:?}"

# Export owner trust settings
gpg --export-ownertrust > "${OWNERTRUST_FILENAME:?}"
```

## Importing Keys

```bash
# Public key
gpg --import "${PUBLIC_KEY_FILENAME:?}"
```

```bash
# Private key; can defer passphrase entry by using --batch
gpg --import "${PRIVATE_KEY_FILENAME:?}"
gpg --import --batch "${PRIVATE_KEY_FILENAME:?}"
```

```bash
# Owner trust settings
gpg --import-ownertrust "${OWNERTRUST_FILENAME:?}"
```

# Encryption & Decryption

Encryption is done using the public key of each intended recipient.

Decryption is only possible with a recipient's private key.

## File Encryption

```bash
SOURCE_FILE='foo.bar'
RECIPIENT_PUBLIC_KEY_EMAIL='someone@example.com'
```

```bash
# Ensure recipient's public key has been imported first
# Use of --sign is optional
gpg \
  --encrypt \
  --sign \
  --output "${SOURCE_FILE:?}.gpg" \
  --recipient "${RECIPIENT_PUBLIC_KEY_EMAIL:?}" \
  "${SOURCE_FILE:?}"
```

The warning:

* `There is no assurance this key belongs to the named user`

Can be suppressed with:

```bash
--trust-model always
```

## File Decryption

```bash
# If encrypted and signed, the signature will be verified 
gpg \
  --output "${ENCRYPTED_FILENAME:?}.decrypted" \
  --decrypt "${ENCRYPTED_FILENAME:?}"
```

# Signing & Signature Verification

## Files

### Signing A File

```bash
# --armor is optional to output in ASCII format
# --local-user is optional
gpg \
  --detach-sign \
  --output "${SOURCE_FILE:?}".sig \
  --armor \
  --local-user "${GPG_KEY_ID:?}" \
  "${SOURCE_FILE:?}"
```

### Verifying A Signed File

```bash
gpg \
    --verify "${SOURCE_FILE:?}".sig \
    "${SOURCE_FILE:?}"
```

## Clear Signing Messages

### Creating

```bash
MESSAGE='The quick brown
fox jumps over
the lazy dog'

echo -n "${MESSAGE:?}" | gpg --local-user "${GPG_KEY_ID:?}" --clearsign
```

### Verifying

```bash
SIGNED_MESSAGE="$(
  echo -n "${MESSAGE:?}" | gpg --local-user "${GPG_KEY_ID:?}" --clearsign
)"

echo -n "${SIGNED_MESSAGE:?}" | gpg --verify
```

# Inspecting GPG Files

```bash
# e.g. to see if an encrypted file is signed
gpg --list-packets "${GPG_FILE:?}"
```

# References

* https://www.gnupg.org/gph/en/manual/book1.html
* https://developer.okta.com/blog/2021/07/07/developers-guide-to-gpg
