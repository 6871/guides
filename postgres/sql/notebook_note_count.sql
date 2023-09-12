SELECT      nb.name     AS notebook,
            COUNT(*)    AS note_count
FROM        notebooks   nb,
            notes       n
WHERE       n.fk_notebook_id = nb.pk_notebook_id
GROUP BY    nb.name
ORDER BY    nb.name;