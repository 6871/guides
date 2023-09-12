-- Example notebooks
INSERT INTO notebooks (name)
VALUES ('Null Data');

-- Example notes
INSERT INTO notes (fk_notebook_id, name, note)
VALUES
    ((SELECT pk_notebook_id FROM notebooks WHERE name = 'Null Data'), 'A', 'Alpha'),
    ((SELECT pk_notebook_id FROM notebooks WHERE name = 'Null Data'), 'B', NULL),
    ((SELECT pk_notebook_id FROM notebooks WHERE name = 'Null Data'), 'C', NULL);
