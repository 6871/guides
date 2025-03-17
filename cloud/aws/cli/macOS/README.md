# AWS CLI macOS setup

* [Overview](#overview)
* [Use](#use)
* [Related links](#related-links)

# Overview

A script to automate installing and updating the
[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-version.html)
utility on macOS:

* [aws_cli_install.sh](aws_cli_install.sh)

Synopsis:

```
./aws_cli_install.sh [--list-latest] [--list-releases] [--version <VERSION>] [--dir <DIRECTORY>]
```

See script [header comment](aws_cli_install.sh) for further details.

# Use

1. Create a root install directory:

   If option `--dir` is omitted, the default root install directory is:

   ```bash
   mkdir -p "${HOME:?}/Applications/aws/cli"
   ```

2. Run the script with no options to install the latest AWS CLI version:

   ```bash
   ./aws_cli_install.sh
   ```

   ℹ️ For updates, the script will print `rm` commands that must be run first. 

# Related links

* https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst
* https://docs.aws.amazon.com/cli/latest/userguide/getting-started-version.html
  * See: `macOS` -> `Installation instructions` -> `Command line - Current user`
