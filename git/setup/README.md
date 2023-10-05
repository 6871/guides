# Git Setup

* [Setup Summary](#setup-summary)
* [Properties](#properties)
    * [Viewing](#viewing)
    * [Setting](#setting)
    * [Removing](#removing)
* [Commit Signing](#commit-signing)
    * [Server Setup](#server-setup)
    * [Client Setup](#client-setup)
* [Using Multiple GitHub Accounts: SSH](#using-multiple-github-accounts-ssh)
* [Troubleshooting: GIT_TRACE](#troubleshooting-gittrace)

# Setup Summary

To configure access to multiple GitHub accounts, see the following section:

* [Using Multiple GitHub Accounts: SSH](#using-multiple-github-accounts-ssh)

To configure user details (current repository):

```bash
# Set user for commit messages
git config user.name "${GIT_USER_NAME:?}"
git config user.email "${GIT_USER_EMAIL:?}"
```

To set up GPG commit signing (current repository):

```bash
# Get user's public key; must be added to user's server-side git config
gpg --armor --export "${GIT_USER_EMAIL:?}"
```

```bash
# Get user's GPG key signature
gpg --list-keys

# Set GPG config for user's commits
git config user.signingkey "${KEY_SIGNATURE:?}"
git config commit.gpgsign true
git config tag.gpgsign true
```

```bash
# To view the applied config
git config --list --show-origin
```

For more information on GPG and commit signing, see section:

* [Commit Signing](#commit-signing)

# Properties

The default Git property configuration scope is the current repository; to
configure a Git property for all repositories use the `--global` option.

## Viewing

```bash
# Use --show-origin to see property scope (repository or global)
git config --list
git config --list --show-origin
```

## Setting

```bash
# Per repository:
git config user.name "${GIT_USER_NAME:?}"
git config user.email "${GIT_USER_EMAIL:?}"

# For all repositories:
git config --global user.name "${GIT_USER_NAME:?}"
git config --global user.email "${GIT_USER_EMAIL:?}"
```

## Removing

```bash
git config --unset "${CONFIG_KEY_NAME:?}"
git config --global --unset "${CONFIG_KEY_NAME:?}"
```

# Commit Signing

This guide uses GPG for Git commit signing.

For more information on GPG see:

* [GPG](../../gpg/README.md)
    * [Key Management](../../gpg/README.md#key-management)
        * [Creating Key Pairs](../../gpg/README.md#creating-key-pairs)
        * [Exporting Keys](../../gpg/README.md#exporting-keys)

## Server Setup

1. Get your public gpg key; for example:

    ```bash
    EMAIL='name@example.com'
   
    # pbcopy copies to the macOS clipboard
    gpg --armor --export "${EMAIL:?}" | pbcopy
    ```

2. Add the public key to your git server; e.g. `New GPG Key` at:

    * [https://github.com/settings/keys](https://github.com/settings/keys)

## Client Setup

1. Get key's signature (also shown in git server UI and key creation output):

    ```bash
    # Lists public keys and signature
    gpg --list-keys
    
    # Lists secret key details
    gpg --list-secret-keys --keyid-format=long
    ```

2. Tell git which GPG key signature to use for signing commits:

    ```bash
    # Key signature may be 40 or 16 characters
    KEY_SIGNATURE=''
   
    # To set per-repository:
    git config user.signingkey "${KEY_SIGNATURE:?}"

    # To set globally:
    git config --global user.signingkey "${KEY_SIGNATURE:?}"
    ```

3. To tell git to sign all commits (optional, see also flags
    `-S[<keyid>], --gpg-sign[=<keyid>], --no-gpg-sign`):

    ```bash
    # To only set for the current repository: 
    git config commit.gpgsign true
    
    # To set for all repositories, use --global:
    git config --global commit.gpgsign true
    ```
   
    ```bash
    # To sign annotated tags by default
    git config tag.gpgsign true
    ```

4. Optionally set gpg program location:

    ```bash
    # --global is optional
    git config --global gpg.program "${GPG_COMMAND_OR_SCRIPT:?}"
    ```

# Using Multiple GitHub Accounts: SSH

SSH `Host` entries can be used to support multiple GitHub accounts.

For example, given the following GitHub accounts:

* Account `github.com/foo` with SSH authentication key `foo_id_rsa`
* Account `github.com/bar` with SSH authentication key `bar_id_rsa`

File `~/.ssh/config` can be updated to contain the following `Host` entries:

```bash
Host *
  UseKeychain yes

Host foo.github.com
  Hostname github.com
  IdentityFile ~/.ssh/foo_id_rsa

Host bar.github.com
  Hostname github.com
  IdentityFile ~/.ssh/bar_id_rsa
```

> ⚠️ `UseKeyChain yes` automates SSH key passphrase entry on macOS only

The `git clone` command can now use the SSH `Host` names as shown here:

```bash
# For account foo, use SSH Host alias foo.github.com (instead of github.com):
git clone git@foo.github.com:foo/example-repository.git

# For account bar, use SSH Host alias bar.github.com (instead of github.com):
git clone git@bar.github.com:bar/example-repository.git
```

The correct `IdentityFile` will be used for repository authentication against
the underlying shared `Hostname`, `github.com`.

See also:

* `man ssh_config`
* [man.openbsd.org/.../ssh_config](https://man.openbsd.org/OpenBSD-current/man5/ssh_config.5)
  * [Host](https://man.openbsd.org/OpenBSD-current/man5/ssh_config.5#Host)
  * [Hostname](https://man.openbsd.org/OpenBSD-current/man5/ssh_config.5#Hostname)
  * [IdentityFile](https://man.openbsd.org/OpenBSD-current/man5/ssh_config.5#IdentityFile)
* [ssh.com/.../config](https://www.ssh.com/academy/ssh/config)


# Troubleshooting: GIT_TRACE

To show git logging information (e.g. to debug a GPG signing issue):

```bash
export GIT_TRACE=1

# To revert:
unset GIT_TRACE
```
