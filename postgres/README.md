# PostgreSQL Guide

* [Running PostgreSQL With Docker Compose](#running-postgresql-with-docker-compose)
  * [Starting & Stopping](#starting--stopping)
  * [Container psql CLI Access](#container-psql-cli-access)
* [Running psql](#running-psql)
* [Running Scripts With psql](#running-scripts-with-psql)
* [Execution Plans](#execution-plans)

# Running PostgreSQL With Docker Compose

The following `docker compose` file runs PostgreSQL locally:

* [compose.yaml](compose.yaml)

ℹ️ Example SQL and bash scripts are mounted in the `postgres-db` container's
`/examples` directory; data is persisted to a volume; port 5432 is exposed

## Starting & Stopping

```bash
# By default these commands look for compose.yaml in the current directory 
docker compose up --detach
docker compose logs --follow
docker compose stop
docker compose down

# To remove DB state persisted in volume "postgres_volume"
docker compose down --volumes
```

## Container psql CLI Access

To access the `postgres-db` container's CLI (e.g. to access `psql`):

```bash
docker compose exec postgres-db bash
```

# Running psql

To run the `psql` client:

```bash
psql --help
```

```bash
psql \
  --host "${POSTGRES_HOST:-localhost}" \
  --port "${POSTGRES_PORT:-5432}" \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres_db}"
```

Some `psql` commands:

| Command                 | Description                              |
|-------------------------|------------------------------------------|
| `\?`                    | Show help                                |
| `\dt`                   | List tables                              |
| `\di`                   | List indexes                             |
| `\dtS`                  | List tables, include system tables       |
| `\d NAME`<br>`\d+ NAME` | Describe table, view, sequence, or index |
| `\i FILE`<br>`\ir FILE` | Execute commands in file                 |

See also:

* https://www.postgresql.org/docs/current/app-psql.html

# Running Scripts With psql

Use command `\i` to run a script from within `psql`; for example:

```postgresql
\i /examples/sql/example.ddl
```

Use the `--file` option to execute a script with `psql`; for example:

```bash
psql \
  --host "${POSTGRES_HOST:-localhost}" \
  --port "${POSTGRES_PORT:-5432}" \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres_db}" \
  --single-transaction \
  --file /examples/sql/example.ddl
```

ℹ️ --single-transaction : execute as a single transaction (if non-interactive)

# Execution Plans

ℹ️ https://www.postgresql.org/docs/current/using-explain.html

Prefix a statement with `EXPLAIN` or `EXPLAIN ANALYSE`:

```
postgres_db=# EXPLAIN
SELECT      nb.name     AS notebook,
            n.name      AS note_name,
            n.note      AS note
FROM        notebooks   nb,
            notes       n
WHERE       n.fk_notebook_id = nb.pk_notebook_id;
                                 QUERY PLAN                                  
-----------------------------------------------------------------------------
 Hash Join  (cost=13.15..24.80 rows=130 width=1064)
   Hash Cond: (n.fk_notebook_id = nb.pk_notebook_id)
   ->  Seq Scan on notes n  (cost=0.00..11.30 rows=130 width=552)
   ->  Hash  (cost=11.40..11.40 rows=140 width=520)
         ->  Seq Scan on notebooks nb  (cost=0.00..11.40 rows=140 width=520)
(5 rows)

postgres_db=# 
```

```
postgres_db=# EXPLAIN ANALYSE
SELECT      nb.name     AS notebook,
            n.name      AS note_name,
            n.note      AS note
FROM        notebooks   nb,
            notes       n
WHERE       n.fk_notebook_id = nb.pk_notebook_id;
                                                      QUERY PLAN                                                       
-----------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=13.15..24.80 rows=130 width=1064) (actual time=0.092..0.096 rows=6 loops=1)
   Hash Cond: (n.fk_notebook_id = nb.pk_notebook_id)
   ->  Seq Scan on notes n  (cost=0.00..11.30 rows=130 width=552) (actual time=0.019..0.020 rows=6 loops=1)
   ->  Hash  (cost=11.40..11.40 rows=140 width=520) (actual time=0.025..0.025 rows=4 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Seq Scan on notebooks nb  (cost=0.00..11.40 rows=140 width=520) (actual time=0.012..0.013 rows=4 loops=1)
 Planning Time: 0.186 ms
 Execution Time: 0.114 ms
(8 rows)

postgres_db=# 
```
