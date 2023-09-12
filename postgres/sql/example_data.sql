-- Example notebooks
INSERT INTO notebooks (name)
VALUES
    ('Foo'),
    ('Bar'),
    ('Baz');

-- Example notes
INSERT INTO notes (fk_notebook_id, name, note)
VALUES
    ((SELECT pk_notebook_id FROM notebooks WHERE name = 'Foo'), 'Delta', 'Δ δ'),
    ((SELECT pk_notebook_id FROM notebooks WHERE name = 'Foo'), 'Oscar', '🎹'),
    ((SELECT pk_notebook_id FROM notebooks WHERE name = 'Bar'), 'Xray', '🩻');
