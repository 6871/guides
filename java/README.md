# Java

* [JDK Providers](#jdk-providers)
* [Installing Open JDK](#installing-open-jdk)
* [Keystore & Truststore](#keystore--truststore)
    * [Creating A Keystore](#creating-a-keystore)

# JDK Providers

* AWS:
    * https://aws.amazon.com/corretto
* Open JDK:
    * https://openjdk.org
    * https://jdk.java.net
        * https://jdk.java.net/20
        * https://jdk.java.net/17
            * https://jdk.java.net/archive
* Oracle:
    * https://www.oracle.com/java/technologies/downloads

# Installing Open JDK

1. Identify download file and checksums:

    ```bash
    # Select download file and identify checksum:
    JAVA_ARCHIVE='openjdk-17.0.2_macos-x64_bin.tar.gz'
    
    DOWNLOAD_URL="https://download.java.net/java/GA/jdk17.0.2/\
    dfd4a8d0985749f896bed50d7138ee7f/8/GPL/${JAVA_ARCHIVE:?}"
    
    EXPECTED_CHECKSUM='b85c4aaf7b141825ad3a0ea34b965e45c15d5963677e9b27235aa05f65c6df06'
    ```

2. Select an installation location; e.g.:

    ```bash
    mkdir java && cd $_
    ```

3. Download the Java archive:

    ```bash
    curl \
      --request GET \
      --location \
      --output "${JAVA_ARCHIVE:?}" \
      "${DOWNLOAD_URL:?}"
    ```

4. Verify the downloaded file's checksum:

    ```bash
    CHECKSUM="$(shasum -a 256 "${JAVA_ARCHIVE:?}" | awk '{print $1}')" 
    
    if [[ "${CHECKSUM:?}" == "${EXPECTED_CHECKSUM:?}" ]]; then
      printf 'Checksum OK\n'
    else
      printf 'Checksum error\n'
      return 1
    fi
    ```

5. Unpack:

    ```bash
    tar --extract --verbose --file "${JAVA_ARCHIVE:?}"
    ```

6. Verify:

   To check compiler version:

    ```bash
    JAVA_HOME="${PWD:?}/jdk-17.0.2.jdk/Contents/Home/bin"
    # Note, need to add downloaded version to path before macOS's /usr/bin/java
    PATH="${JAVA_HOME:?}:$PATH"
    javac --version
    ```

   To run a "Hello, World!" example:

    ```bash
    # Create HelloWorld source file:
    cat << EOF > HelloWorld.java
    class HelloWorld {
        public static void main(String[] args) {
            System.out.println("Hello, World!");
        }
    }
    EOF
    
    # Compile source to class file:
    javac HelloWorld.java
   
    # Run created HelloWorld.class file:
    java HelloWorld
    ```

# Keystore & Truststore

A **Keystore** is typically used to set up an HTTPS endpoint on a server. It
can hold keys and certificates for:

* SSL/TLS encryption
* Code signing
* Client/server authentication

A **Truststore** is typically used by a client to determine if it can trust a
remote host during TLS communication. It can hold trusted CA (Certificate
Authority) X.509 public certificates that are used to establish secure
authenticated connections.

## Creating A Keystore

Optionally start a container and install OpenJDK:

```bash
docker \
  run \
    --rm --tty --interactive --name keytool-demo \
    ubuntu:latest \
      bash -c 'apt-get update \
&& apt-get install --yes openjdk-19-jdk-headless \
&& bash'
```

Create a Keystore file:

```bash
# Define files
KEYSTORE_FILE='./keystore.p12'

# Define the DN (Distinguished Name) string
# Alternative DN format: '/C=GB/O=6871/CN=rh-sso.local.6871.uk'
DISTINGUISHED_NAME='CN=foo.example.com,O=bar,C=GB'

# Create (or set) keystore and key passwords
KEYSTORE_PASSWORD="$(openssl rand -base64 48)"

# For some use cases the keystore and key passwords must be the same
KEYSTORE_KEY_PASSWORD="${KEYSTORE_PASSWORD}"

# Create (or update) keystore with key pair (certificate and private key)
keytool \
  -genkeypair \
    -keystore "${KEYSTORE_FILE:?}" \
    -storepass "${KEYSTORE_PASSWORD:?}" \
    -keyalg RSA \
    -keysize 4096 \
    -validity 365 \
    -dname "${DISTINGUISHED_NAME:?}" \
    -keypass "${KEYSTORE_KEY_PASSWORD:?}" \
    -alias https_cert_foo_example_com

# List (omit -storepass for password prompt)
keytool \
  -list \
    -storepass "${KEYSTORE_PASSWORD:?}" \
    -keystore "${KEYSTORE_FILE:?}"

# Get cert in PEM format (-clcerts = only output client certificates)
# Omit -out to output to STDOUT instead of file
openssl \
  pkcs12 \
    -in "${KEYSTORE_FILE:?}" \
    -passin "pass:${KEYSTORE_PASSWORD:?}" \
    -clcerts \
    -nokeys \
    -out cert.pem

# Get encrypted key in PEM format (-nocerts = don't output certificate)
# Omit -out to output to STDOUT instead of file
EXPORTED_KEY_PASSWORD="$(openssl rand -base64 48)"

openssl \
  pkcs12 \
    -in "${KEYSTORE_FILE:?}" \
    -passin "pass:${KEYSTORE_PASSWORD:?}" \
    -passout "pass:${EXPORTED_KEY_PASSWORD:?}" \
    -nocerts \
    -out private-key-encrypted.pem
    
# Get unencrypted key using -nodes (-nocerts = don't output certificate)
# Omit -out to output to STDOUT instead of file
openssl \
  pkcs12 \
    -in "${KEYSTORE_FILE:?}" \
    -passin "pass:${KEYSTORE_PASSWORD:?}" \
    -nodes \
    -nocerts \
    -out private-key-unencrypted.pem
```
