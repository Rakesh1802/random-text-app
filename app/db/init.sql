CREATE TABLE quotes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    text NVARCHAR(MAX) NOT NULL,
    author NVARCHAR(255) NOT NULL
);

INSERT INTO quotes (text, author) VALUES
('The universe is under no obligation to make sense to you.', 'Neil deGrasse Tyson'),
('Reality is stranger than fiction.', 'Mark Twain'),
('Not all those who wander are lost.', 'J. R. R. Tolkien'),
('I think, therefore I am.', 'René Descartes'),
('The unexamined life is not worth living.', 'Socrates'),
('He who has a why to live can bear almost any how.', 'Friedrich Nietzsche'),
('In the middle of difficulty lies opportunity.', 'Albert Einstein'),
('Man is condemned to be free.', 'Jean-Paul Sartre'),
('That which does not kill us makes us stronger.', 'Friedrich Nietzsche'),
('All animals are equal, but some animals are more equal than others.', 'George Orwell'),
('It is only with the heart that one can see rightly.', 'Antoine de Saint-Exupéry'),
('To be, or not to be, that is the question.', 'William Shakespeare'),
('Not everything that is faced can be changed, but nothing can be changed until it is faced.', 'James Baldwin'),
('If you don’t like your destiny, don’t accept it.', 'Naruto Uzumaki'),
('If you don’t take risks, you can’t create a future.', 'Monkey D. Luffy'),
('The world is cruel, but also very beautiful.', 'Mikasa Ackerman'),
('Throughout heaven and earth, I alone am the honored one.', 'Gojo Satoru'),
('If you win, you live. If you lose, you die. If you don’t fight, you can’t win.', 'Eren Yeager'),
('Humans are so interesting.', 'Ryuk');