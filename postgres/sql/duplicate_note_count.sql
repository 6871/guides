SELECT      n.note,
            COUNT(*)
FROM        notes       n
GROUP BY    n.note
HAVING      COUNT(*) > 1;
