CREATE TABLE quotes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    text NVARCHAR(MAX) NOT NULL
);

INSERT INTO quotes (text) VALUES
('The universe is under no obligation to make sense to you.'),
('Reality is stranger than fiction.'),
('Not all those who wander are lost.');
