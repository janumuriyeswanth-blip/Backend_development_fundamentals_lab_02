const path = require("path");
const sqlite3 = require("sqlite3");
const { open } = require("sqlite");

const dbPath = path.join(__dirname, "books.db");

const initialBooks = [
  { id: 1, title: "The Great Gatsby", author: "F. Scott Fitzgerald", price: 450, pages: 180 },
  { id: 2, title: "To Kill a Mockingbird", author: "Harper Lee", price: 520, pages: 281 },
  { id: 3, title: "1984", author: "George Orwell", price: 399, pages: 328 },
  { id: 4, title: "Pride and Prejudice", author: "Jane Austen", price: 350, pages: 279 },
  { id: 5, title: "The Catcher in the Rye", author: "J.D. Salinger", price: 420, pages: 214 },
  { id: 6, title: "The Hobbit", author: "J.R.R. Tolkien", price: 599, pages: 310 },
  { id: 7, title: "Fahrenheit 451", author: "Ray Bradbury", price: 380, pages: 249 },
  { id: 8, title: "Brave New World", author: "Aldous Huxley", price: 410, pages: 268 },
  { id: 9, title: "Crime and Punishment", author: "Fyodor Dostoevsky", price: 650, pages: 671 },
  { id: 10, title: "The Alchemist", author: "Paulo Coelho", price: 320, pages: 208 }
];

async function initializeDatabase() {
  try {
    const db = await open({
      filename: dbPath,
      driver: sqlite3.Database
    });

    console.log("Connected to SQLite database at:", dbPath);

    await db.exec(`
      CREATE TABLE IF NOT EXISTS book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price INTEGER NOT NULL,
        pages INTEGER NOT NULL
      );
    `);

    const countResult = await db.get("SELECT COUNT(*) AS count FROM book;");
    if (countResult.count === 0) {
      console.log("Seeding initial 10 books...");
      for (const b of initialBooks) {
        await db.run(
          "INSERT INTO book (id, title, author, price, pages) VALUES (?, ?, ?, ?, ?);",
          [b.id, b.title, b.author, b.price, b.pages]
        );
      }
      console.log("Successfully inserted 10 books.");
    } else {
      console.log(`Table 'book' already contains ${countResult.count} records.`);
    }

    const rows = await db.all("SELECT * FROM book;");
    console.log("Current books in database:");
    console.table(rows);

    await db.close();
    console.log("Database initialized and connection closed successfully.");
  } catch (error) {
    console.error("Error initializing database:", error.message);
    process.exit(1);
  }
}

initializeDatabase();
