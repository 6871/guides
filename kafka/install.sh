#!/usr/bin/env bash
# Example Kafka install script.
set -e

function main {
  local SCALA_VERSION='2.13'
  local KAFKA_VERSION='3.5.1'
  local KAFKA_DIR="kafka_${SCALA_VERSION:?}-${KAFKA_VERSION:?}"
  local KAFKA_ARCHIVE="${KAFKA_DIR:?}.tgz"
  local KAFKA_ARCHIVE_DETACHED_SIGNATURE="${KAFKA_ARCHIVE:?}.asc"
  local KAFKA_ARCHIVE_CHECKSUM="${KAFKA_ARCHIVE:?}.sha512"
  local KAFKA_URL="https://downloads.apache.org/kafka/${KAFKA_VERSION:?}"

  # Download archive (.tgz)
  curl --request GET \
    --location \
    --silent \
    --show-error \
    --fail-with-body \
    --output "${KAFKA_ARCHIVE:?}" \
    "${KAFKA_URL:?}/${KAFKA_ARCHIVE:?}"

  # Download archive's detached signature (.asc)
  curl --request GET \
    --location \
    --silent \
    --show-error \
    --fail-with-body \
    --output "${KAFKA_ARCHIVE_DETACHED_SIGNATURE:?}" \
    "${KAFKA_URL:?}/${KAFKA_ARCHIVE_DETACHED_SIGNATURE:?}"

  # Download archive's checksum signature (.sha512)
  curl --request GET \
    --location \
    --silent \
    --show-error \
    --fail-with-body \
    --output "${KAFKA_ARCHIVE_CHECKSUM:?}" \
    "${KAFKA_URL:?}/${KAFKA_ARCHIVE_CHECKSUM:?}"

  # Verify checksum
  if gpg --print-md SHA512 "${KAFKA_ARCHIVE:?}" \
      | diff - "${KAFKA_ARCHIVE_CHECKSUM:?}"
  then
      echo 'Checksum OK'
  else
      echo 'Bad checksum'
      return 1
  fi

  # Get Apache Kafka keys
  curl --request GET \
    --location \
    --silent \
    --show-error \
    --fail-with-body \
    --output apache_kafka_keys.txt \
    'https://downloads.apache.org/kafka/KEYS'

  # Import Apache Kafka keys: note these will not have full "trust"
  gpg --import apache_kafka_keys.txt

  # Verify signature
  if gpg --verify "${KAFKA_ARCHIVE_DETACHED_SIGNATURE:?}" "${KAFKA_ARCHIVE:?}"
  then
      echo 'GPG --verify OK'
  else
      echo 'GPG --verify failed'
      return 1
  fi

  # Install
  tar --extract --gunzip --file "${KAFKA_ARCHIVE:?}"
}

main "$@"
