-- Table definition
CREATE TABLE IF NOT EXISTS book (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  price INTEGER NOT NULL,
  pages INTEGER NOT NULL
);

-- Seed rows (10 sample books)
INSERT INTO book (id, title, author, price, pages) VALUES (1, 'The Great Gatsby', 'F. Scott Fitzgerald', 450, 180);
INSERT INTO book (id, title, author, price, pages) VALUES (2, 'To Kill a Mockingbird', 'Harper Lee', 520, 281);
INSERT INTO book (id, title, author, price, pages) VALUES (3, '1984', 'George Orwell', 399, 328);
INSERT INTO book (id, title, author, price, pages) VALUES (4, 'Pride and Prejudice', 'Jane Austen', 350, 279);
INSERT INTO book (id, title, author, price, pages) VALUES (5, 'The Catcher in the Rye', 'J.D. Salinger', 420, 214);
INSERT INTO book (id, title, author, price, pages) VALUES (6, 'The Hobbit', 'J.R.R. Tolkien', 599, 310);
INSERT INTO book (id, title, author, price, pages) VALUES (7, 'Fahrenheit 451', 'Ray Bradbury', 380, 249);
INSERT INTO book (id, title, author, price, pages) VALUES (8, 'Brave New World', 'Aldous Huxley', 410, 268);
INSERT INTO book (id, title, author, price, pages) VALUES (9, 'Crime and Punishment', 'Fyodor Dostoevsky', 650, 671);
INSERT INTO book (id, title, author, price, pages) VALUES (10, 'The Alchemist', 'Paulo Coelho', 320, 208);
