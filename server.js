const express = require("express");
const path = require("path");
const { open } = require("sqlite");
const sqlite3 = require("sqlite3");

const app = express();
const PORT = process.env.PORT || 3000;
const dbPath = path.join(__dirname, "books.db");

// Student Information
const STUDENT_INFO = {
  name: "Janumuri Yeswanth",
  registrationNumber: "252U1R9046",
  section: "CSE-GEN-AI 2A",
  course: "Backend Development Fundamentals",
  lab: "Lab 2: SQLite database and CRUD routes"
};

// Middleware to parse JSON request bodies
app.use(express.json());

let db = null;

/**
 * Helper to ensure database is opened and table is created
 */
const connectDB = async () => {
  if (!db) {
    db = await open({
      filename: dbPath,
      driver: sqlite3.Database,
    });

    await db.exec(`
      CREATE TABLE IF NOT EXISTS book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price INTEGER NOT NULL,
        pages INTEGER NOT NULL
      );
    `);
  }
  return db;
};

/**
 * Initializes the SQLite database connection and starts the Express server.
 * Ensures the database connection succeeds before listening for HTTP requests.
 */
const initializeDBAndServer = async (port = PORT) => {
  try {
    await connectDB();
    const server = app.listen(port, () => {
      console.log(`Server Running at http://localhost:${port}/`);
    });
    return server;
  } catch (error) {
    console.error(`DB Error: ${error.message}`);
    process.exit(1);
  }
};

// Start the server if this file is run directly
if (require.main === module) {
  initializeDBAndServer();
}

// Student & Lab Info (Welcome Route)
app.get("/", (request, response) => {
  response.status(200).json({
    lab: STUDENT_INFO.lab,
    student: {
      name: STUDENT_INFO.name,
      registrationNumber: STUDENT_INFO.registrationNumber,
      section: STUDENT_INFO.section
    },
    endpoints: {
      "GET /books/": "Retrieve all books",
      "GET /books/:bookId/": "Retrieve a specific book by ID",
      "POST /books/": "Add a new book",
      "PUT /books/:bookId/": "Update an existing book by ID",
      "DELETE /books/:bookId/": "Delete a book by ID"
    }
  });
});

/**
 * 1. GET /books/
 * Retrieves all books from the 'book' table.
 */
app.get("/books/", async (request, response) => {
  try {
    const database = await connectDB();
    const getBooksQuery = `
      SELECT
        *
      FROM
        book
      ORDER BY
        id ASC;
    `;
    const books = await database.all(getBooksQuery);
    response.status(200).json(books);
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

/**
 * 2. GET /books/:bookId/
 * Retrieves a single book by ID using parameterised query (?).
 */
app.get("/books/:bookId/", async (request, response) => {
  try {
    const database = await connectDB();
    const { bookId } = request.params;
    const getBookQuery = `
      SELECT
        *
      FROM
        book
      WHERE
        id = ?;
    `;
    const book = await database.get(getBookQuery, [bookId]);

    if (!book) {
      return response.status(404).json({ error: `Book with ID ${bookId} not found` });
    }

    response.status(200).json(book);
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

/**
 * 3. POST /books/
 * Creates a new book in the 'book' table using parameterised query (?).
 */
app.post("/books/", async (request, response) => {
  try {
    const database = await connectDB();
    const { title, author, price, pages } = request.body;

    // Validation
    if (!title || !author || price === undefined || pages === undefined) {
      return response.status(400).json({
        error: "Missing required fields. Please provide title, author, price, and pages."
      });
    }

    const addBookQuery = `
      INSERT INTO
        book (title, author, price, pages)
      VALUES
        (?, ?, ?, ?);
    `;
    const dbResponse = await database.run(addBookQuery, [title, author, price, pages]);
    const bookId = dbResponse.lastID;

    response.status(201).json({
      message: "Book Added Successfully",
      bookId: bookId
    });
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

/**
 * 4. PUT /books/:bookId/
 * Updates an existing book by ID using parameterised query (?).
 */
app.put("/books/:bookId/", async (request, response) => {
  try {
    const database = await connectDB();
    const { bookId } = request.params;
    const { title, author, price, pages } = request.body;

    // Verify book exists
    const checkBookQuery = `SELECT * FROM book WHERE id = ?;`;
    const existingBook = await database.get(checkBookQuery, [bookId]);

    if (!existingBook) {
      return response.status(404).json({ error: `Book with ID ${bookId} not found` });
    }

    const updateBookQuery = `
      UPDATE
        book
      SET
        title = ?,
        author = ?,
        price = ?,
        pages = ?
      WHERE
        id = ?;
    `;
    await database.run(updateBookQuery, [
      title !== undefined ? title : existingBook.title,
      author !== undefined ? author : existingBook.author,
      price !== undefined ? price : existingBook.price,
      pages !== undefined ? pages : existingBook.pages,
      bookId
    ]);

    response.status(200).json({
      message: "Book Details Updated Successfully"
    });
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

/**
 * 5. DELETE /books/:bookId/
 * Deletes a book by ID using parameterised query (?).
 */
app.delete("/books/:bookId/", async (request, response) => {
  try {
    const database = await connectDB();
    const { bookId } = request.params;

    // Verify book exists
    const checkBookQuery = `SELECT * FROM book WHERE id = ?;`;
    const existingBook = await database.get(checkBookQuery, [bookId]);

    if (!existingBook) {
      return response.status(404).json({ error: `Book with ID ${bookId} not found` });
    }

    const deleteBookQuery = `
      DELETE FROM
        book
      WHERE
        id = ?;
    `;
    await database.run(deleteBookQuery, [bookId]);

    response.status(200).json({
      message: "Book Deleted Successfully"
    });
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

// Wildcard 404 handler for unknown routes
app.use((request, response) => {
  response.status(404).json({ error: "Route not found" });
});

module.exports = { app, initializeDBAndServer, connectDB, STUDENT_INFO };
