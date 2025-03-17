#!/usr/bin/env bash
# Installs AWS CLI utility on macOS.
#
# Running this script with no options installs the latest AWS CLI version in
# a sub-directory of $HOME/Applications/aws/cli. Symlinks are then added to
# /usr/local/bin that point to the installed aws and aws_completer commands.
#
# The root install directory must exist. It can be changed with option --dir.
#
# A specific AWS CLI version can be installed with option --version.
#
# Sudo access is needed to create symlinks in /usr/local/bin for the aws and
# aws_completer commands. If sudo access is not granted in advance, the script
# will prompt for the sudo password, use sudo to create the symlinks, then
# revoke the assumed sudo access.
#
# To re-install a previously installed version, the install directory, and the
# symlinks in /usr/local/bin, must be manually deleted first. The script will
# print the delete commands, but for safety, it does not run them.
#
# Synopsis:
# ./aws_cli_install.sh [--list-latest] [--list-releases] [--version <VERSION>] [--dir <DIRECTORY>]
#
# Options:
# --list-latest
#     Optional. Prints the latest AWS CLI version from the AWS CLI GitHub
#     release page, then exits.
# --list-releases
#     Optional. Prints all AWS CLI versions from the AWS CLI GitHub release
#     page, then exits.
# --version=version, --version version
#     Optional. Installs the specified AWS CLI version. When omitted this
#     defaults to the latest version on the AWS CLI GitHub release page.
# --dir=directory, --dir directory
#     Optional. The root directory in which an install directory is created
#     for each AWS CLI version the script installs. This directory must
#     already exist. Defaults to "$HOME/Applications/aws/cli" when omitted.
set -o errexit -o nounset -o pipefail

#-----------------------------------------------------------------------------
# Uses sudo to create a symlink to a file.
# Parameters:
#   $1 - The path of the file to symlink to
#   $2 - The path of the symlink to be created
function create_symlink_with_sudo {
  local file="${1:?}"
  local symlink="${2:?}"

  if [ -L "${symlink:?}" ]; then
    printf 'Existing symlink found:\n' >&2
    ls -la "${symlink:?}"

    printf 'ERROR: Existing symlink %s must be deleted first.\n' "${symlink:?}" >&2
    return 74
  fi

  printf 'Creating symlink: %s -> %s\n' "${file:?}" "${symlink:?}" >&2
  sudo ln -s "${file:?}" "${symlink:?}"
  local status="$?"

  if [ "${status:?}" -eq 0 ]; then
    printf 'Symlink created\n' >&2
  else
    printf 'ERROR: failed to create symlink %s -> %s\n' "${file:?}" "${symlink:?}" >&2
    return 75
  fi
}

#-----------------------------------------------------------------------------
# Create symlinks for AWS CLI commands aws and aws_completer. If sudo access
# is not already enabled, enable it temporarily.
# Parameters:
#   $1 - The directory in which the AWS CLI version to use is installed.
#   $2 - The directory in which to create the symlinks.
function create_aws_cli_symlinks_with_sudo {
  local version_install_dir="${1:?}"
  local symlink_dir="${2:?}"
  local existing_sudo_access='false'

  if sudo -n true 2>/dev/null; then
    existing_sudo_access='true'
  fi

  printf 'Checking sudo access: sudo password entry may be required to create AWS command symlinks in %s ...\n' \
    "${symlink_dir:?}" >&2

  if sudo -v; then
    printf 'Sudo access confirmed.\n' >&2
  else
    printf 'ERROR: Failed to assume sudo access.\n' >&2
    return 73
  fi

  local installed_command_dir="${version_install_dir:?}/aws-cli"

  create_symlink_with_sudo "${installed_command_dir:?}/aws" "${symlink_dir:?}/aws"
  create_symlink_with_sudo "${installed_command_dir:?}/aws_completer" "${symlink_dir:?}/aws_completer"

  if [ "${existing_sudo_access:?}" = 'true' ]; then
    printf 'Not revoking sudo access as it was already available.\n' >&2
  else
    sudo --remove-timestamp
    printf 'Revoked sudo access that was assumed by this script.\n' >&2
  fi
}

#-----------------------------------------------------------------------------
# Create the AWS CLI package install config file with the custom install
# location set.
# Parameters:
#   $1 - The full path of the config file to be created.
#   $2 - The directory into which the AWS CLI will be installed.
function create_installer_config_file {
  local xml_config_file="${1:?}"
  local version_install_dir="${2:?}"

  if [ -f "${xml_config_file:?}" ]; then
    printf 'Install config file %s already exists, to re-install, please delete it first.\n' "${xml_config_file}" >&2
    return 72
  fi

  cat << EOF > "${xml_config_file:?}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <array>
    <dict>
      <key>choiceAttribute</key>
      <string>customLocation</string>
      <key>attributeSetting</key>
      <string>${version_install_dir:?}</string>
      <key>choiceIdentifier</key>
      <string>default</string>
    </dict>
  </array>
</plist>
EOF

  printf 'Created config file %s:\n' "${xml_config_file:?}" >&2
  cat "${xml_config_file:?}" >&2
}

#-----------------------------------------------------------------------------
# Download and install the requested AWS CLI version.
# Parameters:
#   $1 - Root install directory.
#   $2 - Directory where AWS CLI version will be installed.
#   $3 - AWS CLI version to install.
function install_aws_cli {
  local root_install_dir="${1:?}"
  local version_install_dir="${2:?}"
  local aws_cli_version="${3:?}"

  if [ ! -d "${root_install_dir:?}" ]; then
    printf 'ERROR: Root install directory %s does not exist, please create it first.\n' "${root_install_dir:?}" >&2
    return 68
  fi

  cd "${root_install_dir:?}" || return 69

  if [ -d "${aws_cli_version:?}" ]; then
    tput setaf 1 # red
    printf 'ERROR: Install directory for AWS CLI version %s already exists; to re-install, first delete it with:\n' \
      "${aws_cli_version}"

    tput setaf 3 # yellow
    printf 'rm -rf %s\n' " '${root_install_dir:?}/${aws_cli_version:?}'" >&2
    tput sgr 0 # clear

    return 70
  fi

  mkdir "${version_install_dir:?}" || return 71

  local aws_cli_package="${version_install_dir:?}/AWSCLIV2.pkg"
  local aws_cli_download_url="https://awscli.amazonaws.com/AWSCLIV2-${aws_cli_version:?}.pkg"

  printf 'Downloading %s to %s ...\n' "${aws_cli_download_url:?}" "${aws_cli_package:?}" >&2
  curl \
    --request GET \
    --location \
    --fail \
    --output "${aws_cli_package:?}" \
    "${aws_cli_download_url:?}"

  local xml_config_file="${version_install_dir:?}/choices.xml"
  create_installer_config_file "${xml_config_file:?}" "${version_install_dir:?}"

  installer \
    -pkg "${aws_cli_package:?}" \
    -target CurrentUserHomeDirectory \
    -applyChoiceChangesXML "${xml_config_file:?}"
}

#-----------------------------------------------------------------------------
# Parse input arguments and perform the required action, which may be:
# - Install the AWS CLI
# - Print the latest AWS CLI version (--list-latest)
# - Print the available AWS CLI versions (--list-releases)
#
# Parameters:
#   [--list-latest]
#   [--list-releases]
#   [--version <VERSION>]
#   [--dir <DIRECTORY>]
function parse_args {
  if [[ "$(uname)" != 'Darwin' ]]; then
    printf 'ERROR: This script is intended for macOS only.\n' >&2
    exit 64
  fi

  local aws_cli_version
  local root_install_dir="${HOME:?}/Applications/aws/cli"
  local list_releases='false'
  local list_latest_release='false'

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --list-latest)
        list_latest_release='true'
        shift 1
        ;;
      --list-releases)
        list_releases='true'
        shift 1
        ;;
      --version)
        aws_cli_version="${2:?}"
        shift 2
        ;;
      --version=*)
        aws_cli_version="${1#*=}"
        shift 1
        ;;
      --dir)
        root_install_dir="${2:?}"
        shift 2
        ;;
      --dir=*)
        root_install_dir="${1#*=}"
        shift 1
        ;;
      *)
        printf 'ERROR: unknown option: %s\n' "$1" >&2
        return 65
        ;;
    esac
  done

  local aws_cli_release_notes_url='https://raw.githubusercontent.com/aws/aws-cli/refs/heads/v2/CHANGELOG.rst'
  local aws_cli_version_list
  aws_cli_version_list="$( \
    printf 'Getting AWS CLI versions from %s ...\n' "${aws_cli_release_notes_url:?}" >&2
    curl --silent "${aws_cli_release_notes_url:?}" \
    | grep --extended-regexp --only-matching '^v?[0-9]+\.[0-9]+\.[0-9]+' \
  )"

  local aws_cli_latest_version
  aws_cli_latest_version="$(echo "${aws_cli_version_list:?}" | head --lines 1)"

  if [ "${list_releases:?}" = 'true' ]; then
    printf 'AWS CLI versions:\n%s\n' "${aws_cli_version_list//$'\n'/ }" >&2
    return 0
  fi

  if [ "${list_latest_release:?}" = 'true' ]; then
    printf 'AWS CLI latest version: %s\n' "${aws_cli_latest_version//$'\n'/ }" >&2
    return 0
  fi

  if [[ -z "${aws_cli_version}" ]]; then
    aws_cli_version="${aws_cli_latest_version:?}"
    printf 'No version given, using latest: %s\n' "${aws_cli_version}" >&2
  else
    if grep --fixed-strings --line-regexp --quiet "${aws_cli_version:?}" <<< "${aws_cli_version_list:?}"; then
      printf 'Version %s found in AWS CLI release notes.\n' "${aws_cli_version:?}" >&2
    else
      printf 'ERROR: Version %s not found in AWS CLI release notes.\n' "${aws_cli_version:?}" >&2
      return 66
    fi
  fi

  local symlink_dir='/usr/local/bin'
  local symlink_aws="${symlink_dir:?}/aws"
  local symlink_aws_completer="${symlink_dir:?}/aws_completer"

  if [ -L "${symlink_aws:?}" ] || [ -L "${symlink_aws_completer:?}" ]; then
    [ -L "${symlink_aws:?}" ] && ls -l "${symlink_aws:?}"
    [ -L "${symlink_aws_completer:?}" ] && ls -l "${symlink_aws_completer:?}"

    tput setaf 1 # red
    printf 'ERROR: Existing AWS CLI command symlink(s) found; to proceed with this install, first delete them with:\n'
    tput setaf 3 # yellow
    printf 'sudo rm %s; sudo rm %s\n' "${symlink_aws:?}" "${symlink_aws_completer:?}" >&2
    tput sgr 0 # clear
    exit 67
  fi

  local version_install_dir="${root_install_dir:?}/${aws_cli_version:?}"
  install_aws_cli "${root_install_dir:?}" "${version_install_dir:?}" "${aws_cli_version:?}"
  create_aws_cli_symlinks_with_sudo "${version_install_dir:?}" "${symlink_dir:?}"

  printf 'Running: aws --version ...\n' >&2
  aws --version >&2

  local zshrc_update
  zshrc_update='cat << '"'"'EOF'"'"' >> ~/.zshrc
# AWS CLI version '"${aws_cli_version:?}"' auto-complete ('"$0"', '"$(date +"%Y-%m-%dT%H:%M:%S%z %Z")"')
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '"'""${symlink_aws_completer:?}""'"' aws
EOF'

  tput setaf 4 # blue
  printf 'AWS CLI auto-complete can be enabled with the following:\n' >&2
  tput setaf 2 # green
  echo "${zshrc_update}" >&2
  tput sgr 0 # clear

  printf 'Install complete for AWS CLI version %s.\n' "${aws_cli_version:?}" >&2
}

#-----------------------------------------------------------------------------
# Entrypoint:
parse_args "$@"
