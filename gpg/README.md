# GPG

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
gpg --armor --export "${EMAIL:?}" --output "${PUBLIC_KEY_FILENAME:?}"

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
# Must have imported recipient's public key first
# Use of --sign is optional
gpg \
  --encrypt \
  --sign \
  --output "${FILENAME_TO_ENCRYPT:?}.gpg" \
  --recipient "${GPG_KEY_EMAIL:?}" \
  "${FILENAME_TO_ENCRYPT:?}"
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
fox jumped over
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
