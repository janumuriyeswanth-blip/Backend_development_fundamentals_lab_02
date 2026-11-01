const http = require("http");
const { app, initializeDBAndServer } = require("./server");

const TEST_PORT = 3003;

function request(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = "";
      res.on("data", (chunk) => {
        body += chunk;
      });
      res.on("end", () => {
        let parsed = null;
        try {
          parsed = JSON.parse(body);
        } catch (e) {
          parsed = body;
        }
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: parsed,
          rawBody: body
        });
      });
    });

    req.on("error", reject);

    if (data) {
      req.write(typeof data === "string" ? data : JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log("=================================================");
  console.log("  LAB 2: SQLite Database & CRUD Routes Test Suite");
  console.log("=================================================\n");

  const server = await initializeDBAndServer(TEST_PORT);

  let passed = 0;
  let failed = 0;
  let createdBookId = null;

  try {
    // Test 1: GET / (Root info)
    console.log("[TEST 1] GET / (Root Welcome & Student Details)");
    const res1 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: "/",
      method: "GET"
    });
    if (
      res1.statusCode === 200 &&
      res1.body.student &&
      res1.body.student.name === "Janumuri Yeswanth" &&
      res1.body.student.registrationNumber === "252U1R9046" &&
      res1.body.student.section === "CSE-GEN-AI 2A"
    ) {
      console.log(`  PASSED: Status ${res1.statusCode}, Student: ${res1.body.student.name} (${res1.body.student.registrationNumber}, ${res1.body.student.section})\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res1.statusCode}, Body:`, res1.body, "\n");
      failed++;
    }

    // Test 2: GET /books/ (Retrieve all books)
    console.log("[TEST 2] GET /books/ (Retrieve all books)");
    const res2 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: "/books/",
      method: "GET"
    });
    if (res2.statusCode === 200 && Array.isArray(res2.body) && res2.body.length >= 8) {
      console.log(`  PASSED: Status ${res2.statusCode}, Retrieved ${res2.body.length} books.`);
      console.log(`  First item: [ID ${res2.body[0].id}] "${res2.body[0].title}" by ${res2.body[0].author}\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res2.statusCode}, Body:`, res2.body, "\n");
      failed++;
    }

    // Test 3: GET /books/1/ (Retrieve single book)
    console.log("[TEST 3] GET /books/1/ (Retrieve single book by ID)");
    const res3 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: "/books/1/",
      method: "GET"
    });
    if (res3.statusCode === 200 && res3.body.id === 1) {
      console.log(`  PASSED: Status ${res3.statusCode}, Title: "${res3.body.title}", Price: ₹${res3.body.price}\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res3.statusCode}\n`);
      failed++;
    }

    // Test 4: GET /books/9999/ (404 Not Found)
    console.log("[TEST 4] GET /books/9999/ (Non-existent book -> 404 Not Found)");
    const res4 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: "/books/9999/",
      method: "GET"
    });
    if (res4.statusCode === 404 && res4.body.error) {
      console.log(`  PASSED: Status ${res4.statusCode}, Error: "${res4.body.error}"\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res4.statusCode}\n`);
      failed++;
    }

    // Test 5: POST /books/ (Add new book)
    console.log("[TEST 5] POST /books/ (Add new book)");
    const newBook = {
      title: "Clean Code",
      author: "Robert C. Martin",
      price: 750,
      pages: 464
    };
    const res5 = await request(
      {
        hostname: "127.0.0.1",
        port: TEST_PORT,
        path: "/books/",
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        }
      },
      newBook
    );
    if (res5.statusCode === 201 && res5.body.bookId) {
      createdBookId = res5.body.bookId;
      console.log(`  PASSED: Status ${res5.statusCode}, Message: "${res5.body.message}", Created ID: ${createdBookId}\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res5.statusCode}, Body:`, res5.body, "\n");
      failed++;
    }

    // Test 6: GET /books/:bookId/ to verify POST persistence
    console.log(`[TEST 6] GET /books/${createdBookId}/ (Verify newly created book)`);
    const res6 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: `/books/${createdBookId}/`,
      method: "GET"
    });
    if (res6.statusCode === 200 && res6.body.title === "Clean Code" && res6.body.pages === 464) {
      console.log(`  PASSED: Verified book in DB: "${res6.body.title}" by ${res6.body.author}\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res6.statusCode}\n`);
      failed++;
    }

    // Test 7: PUT /books/:bookId/ (Update book)
    console.log(`[TEST 7] PUT /books/${createdBookId}/ (Update book details)`);
    const updatedBook = {
      title: "Clean Code (2nd Edition)",
      author: "Robert C. Martin",
      price: 820,
      pages: 480
    };
    const res7 = await request(
      {
        hostname: "127.0.0.1",
        port: TEST_PORT,
        path: `/books/${createdBookId}/`,
        method: "PUT",
        headers: {
          "Content-Type": "application/json"
        }
      },
      updatedBook
    );
    if (res7.statusCode === 200 && res7.body.message.includes("Updated")) {
      console.log(`  PASSED: Status ${res7.statusCode}, Message: "${res7.body.message}"\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res7.statusCode}\n`);
      failed++;
    }

    // Test 8: GET /books/:bookId/ to verify PUT persistence
    console.log(`[TEST 8] GET /books/${createdBookId}/ (Verify updated book)`);
    const res8 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: `/books/${createdBookId}/`,
      method: "GET"
    });
    if (res8.statusCode === 200 && res8.body.title === "Clean Code (2nd Edition)" && res8.body.price === 820) {
      console.log(`  PASSED: Updated data verified: "${res8.body.title}", Price ₹${res8.body.price}\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res8.statusCode}\n`);
      failed++;
    }

    // Test 9: DELETE /books/:bookId/ (Delete book)
    console.log(`[TEST 9] DELETE /books/${createdBookId}/ (Delete book)`);
    const res9 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: `/books/${createdBookId}/`,
      method: "DELETE"
    });
    if (res9.statusCode === 200 && res9.body.message.includes("Deleted")) {
      console.log(`  PASSED: Status ${res9.statusCode}, Message: "${res9.body.message}"\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res9.statusCode}\n`);
      failed++;
    }

    // Test 10: GET /books/:bookId/ to verify DELETE persistence
    console.log(`[TEST 10] GET /books/${createdBookId}/ (Verify book was removed)`);
    const res10 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: `/books/${createdBookId}/`,
      method: "GET"
    });
    if (res10.statusCode === 404) {
      console.log(`  PASSED: Status 404 as expected. Book was successfully removed from database.\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res10.statusCode}\n`);
      failed++;
    }

    // Test 11: POST /books/ validation (Missing fields -> 400 Bad Request)
    console.log("[TEST 11] POST /books/ (Missing required fields -> 400 Bad Request)");
    const res11 = await request(
      {
        hostname: "127.0.0.1",
        port: TEST_PORT,
        path: "/books/",
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        }
      },
      { title: "Incomplete Book" }
    );
    if (res11.statusCode === 400 && res11.body.error) {
      console.log(`  PASSED: Status ${res11.statusCode}, Error: "${res11.body.error}"\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res11.statusCode}\n`);
      failed++;
    }

    // Test 12: PUT /books/9999/ (Update non-existent -> 404)
    console.log("[TEST 12] PUT /books/9999/ (Update non-existent book -> 404 Not Found)");
    const res12 = await request(
      {
        hostname: "127.0.0.1",
        port: TEST_PORT,
        path: "/books/9999/",
        method: "PUT",
        headers: {
          "Content-Type": "application/json"
        }
      },
      { title: "Ghost Book", author: "Nobody", price: 100, pages: 10 }
    );
    if (res12.statusCode === 404) {
      console.log(`  PASSED: Status ${res12.statusCode}, Error: "${res12.body.error}"\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res12.statusCode}\n`);
      failed++;
    }

    // Test 13: DELETE /books/9999/ (Delete non-existent -> 404)
    console.log("[TEST 13] DELETE /books/9999/ (Delete non-existent book -> 404 Not Found)");
    const res13 = await request({
      hostname: "127.0.0.1",
      port: TEST_PORT,
      path: "/books/9999/",
      method: "DELETE"
    });
    if (res13.statusCode === 404) {
      console.log(`  PASSED: Status ${res13.statusCode}, Error: "${res13.body.error}"\n`);
      passed++;
    } else {
      console.error(`  FAILED: Status ${res13.statusCode}\n`);
      failed++;
    }
  } catch (err) {
    console.error("Test execution encountered an error:", err);
    failed++;
  } finally {
    server.close();
    console.log("=================================================");
    console.log(`TEST SUMMARY: ${passed} Passed, ${failed} Failed out of ${passed + failed} Tests`);
    console.log("=================================================");
    if (failed > 0) {
      process.exit(1);
    }
  }
}

runTests();
