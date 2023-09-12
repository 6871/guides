-- A notebook contains zero or more notes
CREATE TABLE notebooks
(
    pk_notebook_id SERIAL PRIMARY KEY,
    name           VARCHAR(255) NOT NULL
);

-- A note belongs to a notebook
CREATE TABLE notes
(
    pk_note_id     SERIAL PRIMARY KEY,
    fk_notebook_id INT REFERENCES notebooks (pk_notebook_id) ON DELETE CASCADE,
    name           VARCHAR(255) NOT NULL,
    note           TEXT
);

-- Create index on foreign key column
CREATE INDEX idx_notes_fk_notebook_id ON notes (fk_notebook_id);
