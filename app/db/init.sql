IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'quotes'
)
BEGIN
    CREATE TABLE quotes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        text NVARCHAR(MAX) NOT NULL,
        author NVARCHAR(255) NOT NULL
    );
END;

INSERT INTO quotes (text, author)
SELECT v.text, v.author
FROM (VALUES
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
    ('If you don’t take risks, you can’t create a future.', 'Monkey D. Luffy'),
    ('The world is cruel, but also very beautiful.', 'Mikasa Ackerman'),
    ('Throughout heaven and earth, I alone am the honored one.', 'Gojo Satoru'),
    ('The greatest glory in living lies not in never falling, but in rising every time we fall', 'Nelson Mandela'),
    ('The two most powerful warriors are patience and time', 'Leo Tolstoy'),
    ('I will leave tomorrows problems to tomorrows me.', 'Saitama'),
    ('Be the change you wish to see in the world', 'Mahatma Gandhi'),
    ('The journey of a thousand miles begins with one step', 'Lao Tzu'),
    ('Life is like riding a bicycle. To keep your balance, you must keep moving', 'Albert Einstein'),
    ('Compare yourself to who you were yesterday, not to who someone else is today.', 'Jordan B. Peterson'),
    ('The only true wisdom is in knowing you know nothing.', 'Socrates'),
    ('Be water, my friend.', 'Bruce Lee'),
    ('If you win, you live. If you lose, you die. If you don’t fight, you can’t win.', 'Eren Yeager')
) AS v(text, author)
WHERE NOT EXISTS (
    SELECT 1
    FROM quotes q
    WHERE q.text = v.text
      AND q.author = v.author
);