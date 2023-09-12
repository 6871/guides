EXPLAIN
SELECT      nb.name     AS notebook,
            n.name      AS note_name,
            n.note      AS note
FROM        notebooks   nb,
            notes       n
WHERE       n.fk_notebook_id = nb.pk_notebook_id;
