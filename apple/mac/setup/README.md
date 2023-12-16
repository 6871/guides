# macOS Setup

* [GPG](#gpg)
* [SSH](#ssh)
* [GitHub](#github)
* [ZSH](#zsh)

## GPG

1. Install GPG

    * [gpg](../../../gpg)
      * [README.md](../../../gpg/README.md)
        * [Install GPGTools (macOS)](../../../gpg/README.md#install-gpgtools-macos)

2. Identify, create or import required GPG key pair(s):

    * [gpg](../../../gpg)
      * [README.md](../../../gpg/README.md)
        * [Listing Keys](../../../gpg/README.md#listing-keys)
        * [Creating Key Pairs](../../../gpg/README.md#creating-key-pairs)
        * [Importing Keys](../../../gpg/README.md#importing-keys)

## SSH

Create machine/user-specific SSH key pair:

* [ssh](../../../ssh)
  * [README.md](../../../ssh/README.md)
    * [Create SSH Key Pair](../../../ssh/README.md#create-ssh-key-pair)

## GitHub

1. Clone required GitHub repositories:

    * [git](../../../git)
      * [setup](../../../git/setup)
        * [README.md](../../../git/setup/README.md)
      * [use](../../../git/use)
        * [README.md](../../../git/use/README.md)
          * [Cloning Multiple Repositories](../../../git/use/README.md#cloning-multiple-repositories)

2. Set configuration for each GitHub repository; e.g. for repository `guides` in account `6871`:

    ```bash
    # Navigate to a repository directory; e.g.:
    cd "${HOME:?}/data/github.com/6871/guides"
    ```
   
    ```bash
    # View repository configuration with
    git config --list --show-origin
    ```
   
    ```bash
    # Set user details; adjust accordingly
    GIT_USER_NAME='6871'
    GIT_USER_EMAIL='55576043+6871@users.noreply.github.com'
   
    git config user.name "${GIT_USER_NAME:?}"
    git config user.email "${GIT_USER_EMAIL:?}"
    ```

    ```bash
    # Set commit and tag signing details; adjust accordingly
    # View available key fingerprints with: gpg --list-keys
    GIT_USER_GPG_KEY_FINGERPRINT='D24A99FCBE3E325692522E6702E2BD896F55669F'
   
    git config user.signingkey "${GIT_USER_GPG_KEY_FINGERPRINT:?}"
    git config commit.gpgsign true
    git config tag.gpgsign true
    ```

## ZSH

1. Add required `.zprofile` content; e.g.:

    ```bash
    # Add Visual Studio Code (code)
    export PATH="$PATH:$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    ```

2. Add required `.zshrc` content:

    ```bash
    cat <<EOF >> ~/.zshrc
    # Load file utility functions
    source '${HOME:?}/data/github.com/6871/scripts/macOS/bash/file_utils.sh'
    
    # Load time utility functions
    source '${HOME:?}/data/github.com/6871/scripts/bash/time_utils.sh'
      
    # %F = foreground colour (%F or %f to reset default)
    # #1~ = working dir, or ~ if none
    # %# = # if elevated, % if not
    PROMPT='%F{4}%1~%F{8} %#%f '
    
    # Prevent consecutive duplicate values in history    
    setopt hist_ignore_dups

    # Navigate past multi-line commands in shell history
    bindkey '^P' up-history
    bindkey '^N' down-history

    # Enable ls colour    
    alias ls='ls -G'
    alias ll='ls -laG'

    # Markdown ToC generator
    alias md_toc.py='${HOME:?}/data/github.com/6871/scripts/python/md_toc.py'    
    EOF
    ```
