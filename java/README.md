# Java

## JDK Implementations

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


## Installing Open JDK

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
