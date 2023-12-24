# CLI Disk Image Write 

1. Get source image:

    For example: 
 
    ```bash
    UBUNTU_ARCHIVE='ubuntu-23.10-preinstalled-server-arm64+raspi.img.xz'
    UBUNTU_IMAGE_URL="https://cdimage.ubuntu.com/releases/mantic/release/${UBUNTU_ARCHIVE:?}"
    UBUNTU_CHECKSUMS='SHA256SUMS'
    UBUNTU_CHECKSUMS_URL="https://cdimage.ubuntu.com/releases/mantic/release/${UBUNTU_CHECKSUMS:?}"
    ```
    
    ```bash
    # Get image file
    curl \
      --request GET \
      --location \
      --show-error \
      --fail-with-body \
      --output "${UBUNTU_ARCHIVE:?}" \
      "${UBUNTU_IMAGE_URL:?}"
    
    # Optionally get checksum file
    curl \
      --request GET \
      --location \
      --show-error \
      --fail-with-body \
      --output "${UBUNTU_CHECKSUMS:?}" \
      "${UBUNTU_CHECKSUMS_URL:?}"
    ```

2. Identify target disk:

    Eject **all** removable disks to reduce the risk of selecting the wrong device.

    Identify existing disks by running:

    ```bash
    diskutil list
    ```

    Insert the target disk and run the following:

    ```bash
    diskutil list
    ```

    Identify the new entry for the target disk (i.e. `/dev/diskX`, with `X` being the target disk's number).

3. Wipe target disk:

    This step ensures any existing partition table is removed.

    Ensure the correct target disk is identified.

    ```bash
    # May need to unmount disk; use buffered (not raw) disk for diskutil
    diskutil unmountDisk /dev/diskX
    
    sudo dd if=/dev/zero of=/dev/rdiskX bs=1m status=progress
    ```

4. Write image to target disk:

    Ensure the correct target disk is identified.

    An `xz` image file can be decompressed and written in one step as follows:

    ```bash
    # On macOS 14.2.1 use gunzip to decompress an xz file
    gunzip --to-stdout "${UBUNTU_ARCHIVE:?}" \
      | sudo dd of=/dev/rdiskX bs=4m status=progress
    
    # On Linux use xzcat instead
    xzcat "${UBUNTU_ARCHIVE:?}" \ 
      | sudo dd of=/dev/rdiskX bs=4m status=progress
    ```
    
    Or to write an uncompressed input file, use the `dd` command's `if` option; e.g.:

    ```bash
    sudo dd \
      if="${UNCOMPRESSED_IMAGE_FILE_NAME:?}" \
      of=/dev/rdiskX bs=4m status=progress
    ```

5. Eject target disk:

    ```bash
    diskutil eject /dev/rdiskX
    ```
