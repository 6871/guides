#!/usr/bin/env bash
# Script to run PostgreSQL psql client, passing any given parameters.
psql \
  --host "${POSTGRES_HOST:-localhost}" \
  --port "${POSTGRES_PORT:-5432}" \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres_db}" \
  "$@"
