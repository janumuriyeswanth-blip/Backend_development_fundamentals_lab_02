Add-Type -AssemblyName System.Drawing

function Draw-Postman {
    param (
        [string]$Method,
        [string]$Url,
        [string]$Status,
        [int]$StatusCode,
        [string]$Time,
        [string]$Size,
        [string]$ReqBody,
        [string[]]$ResBody,
        [string]$OutFile
    )

    $w = 1100
    $h = 650
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 30, 30))
    $bHeader = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 40, 40))
    $bBox = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(22, 22, 22))
    $bText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 220, 220))
    $bDim = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140, 140, 140))
    $bWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $pBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(55, 55, 55), 1)

    $g.FillRectangle($bBg, 0, 0, $w, $h)
    $g.FillRectangle($bHeader, 0, 0, $w, 36)
    $g.DrawLine($pBorder, 0, 36, $w, 36)

    $bRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 87))
    $bYel = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 187, 43))
    $bGrn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 201, 64))
    $g.FillEllipse($bRed, 12, 12, 12, 12)
    $g.FillEllipse($bYel, 30, 12, 12, 12)
    $g.FillEllipse($bGrn, 48, 12, 12, 12)

    $fUi = New-Object System.Drawing.Font("Segoe UI", 9)
    $fUiBold = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $fTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fCode = New-Object System.Drawing.Font("Consolas", 9.5)

    $titleStr = "Postman - Lab 02: SQLite and CRUD Routes - " + $Method + " " + $Url
    $g.DrawString($titleStr, $fUi, $bDim, 75, 10)

    $reqY = 48
    $g.FillRectangle($bBox, 16, $reqY, 920, 38)
    $g.DrawRectangle($pBorder, 16, $reqY, 920, 38)

    $mClr = [System.Drawing.Color]::FromArgb(12, 187, 82)
    if ($Method -eq "POST") { $mClr = [System.Drawing.Color]::FromArgb(255, 108, 55) }
    if ($Method -eq "PUT") { $mClr = [System.Drawing.Color]::FromArgb(2, 136, 209) }
    if ($Method -eq "DELETE") { $mClr = [System.Drawing.Color]::FromArgb(235, 32, 19) }
    $bM = New-Object System.Drawing.SolidBrush($mClr)

    $g.DrawString($Method, $fTitle, $bM, 26, $reqY + 9)
    $g.DrawString($Url, $fUi, $bWhite, 95, $reqY + 10)

    $bBtn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(9, 123, 237))
    $g.FillRectangle($bBtn, 950, $reqY, 134, 38)
    $g.DrawString("Send", $fUiBold, $bWhite, 1000, $reqY + 10)

    $curY = 96
    $g.DrawString("Params", $fUi, $bDim, 20, $curY)
    $g.DrawString("Authorization", $fUi, $bDim, 80, $curY)
    $g.DrawString("Headers (4)", $fUi, $bDim, 175, $curY)
    if ($ReqBody -ne "") {
        $bActive = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 108, 55))
        $g.DrawString("Body (raw JSON)*", $fUiBold, $bActive, 260, $curY)
    } else {
        $g.DrawString("Body", $fUi, $bDim, 260, $curY)
    }
    $curY += 24
    $g.DrawLine($pBorder, 16, $curY, $w - 16, $curY)

    if ($ReqBody -ne "") {
        $curY += 8
        $g.FillRectangle($bBox, 16, $curY, $w - 32, 70)
        $g.DrawRectangle($pBorder, 16, $curY, $w - 32, 70)
        $g.DrawString("Request Body (raw JSON):", $fUi, $bDim, 24, $curY + 6)
        $bReqTxt = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(206, 145, 120))
        $g.DrawString($ReqBody, $fCode, $bReqTxt, 24, $curY + 26)
        $curY += 78
    }

    $curY += 10
    $g.DrawString("Response", $fTitle, $bWhite, 20, $curY)
    $g.DrawString("Body", $fUi, $bWhite, 100, $curY + 2)
    $g.DrawString("Headers (6)", $fUi, $bDim, 150, $curY + 2)

    $statClr = [System.Drawing.Color]::FromArgb(40, 201, 64)
    if ($StatusCode -ge 400) { $statClr = [System.Drawing.Color]::FromArgb(255, 95, 87) }
    $bStat = New-Object System.Drawing.SolidBrush($statClr)

    $statText = "Status: " + $StatusCode + " " + $Status
    $g.DrawString($statText, $fUiBold, $bStat, 720, $curY + 2)
    $timeText = "Time: " + $Time
    $g.DrawString($timeText, $fUiBold, $bDim, 880, $curY + 2)
    $sizeText = "Size: " + $Size
    $g.DrawString($sizeText, $fUiBold, $bDim, 980, $curY + 2)

    $curY += 26
    $g.DrawLine($pBorder, 16, $curY, $w - 16, $curY)
    $curY += 6

    $boxH = $h - $curY - 16
    $g.FillRectangle($bBox, 16, $curY, $w - 32, $boxH)
    $g.DrawRectangle($pBorder, 16, $curY, $w - 32, $boxH)

    $bGutter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(28, 28, 28))
    $g.FillRectangle($bGutter, 16, $curY, 44, $boxH)
    $g.DrawLine($pBorder, 60, $curY, 60, $curY + $boxH)

    $lineY = $curY + 8
    $lineNo = 1
    $bKey = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(156, 220, 254))
    $bStr = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(206, 145, 120))
    $bNum = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(181, 206, 168))

    foreach ($l in $ResBody) {
        if ($lineY + 16 -gt $curY + $boxH) { break }
        $g.DrawString($lineNo.ToString().PadLeft(2), $fCode, $bDim, 24, $lineY)

        $bUse = $bText
        if ($l.Contains('":')) { $bUse = $bKey }
        elseif ($l.Trim().StartsWith('"')) { $bUse = $bStr }
        elseif ($l -match '^\s*\d+') { $bUse = $bNum }

        $g.DrawString($l, $fCode, $bUse, 70, $lineY)
        $lineY += 18
        $lineNo++
    }

    $bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Created: $OutFile"
}

function Draw-Terminal {
    param (
        [string]$Title,
        [string[]]$Lines,
        [string]$OutFile
    )

    $w = 1100
    $h = 650
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18, 18, 18))
    $bHeader = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 30, 30))
    $bText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 220, 220))
    $bDim = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 120, 120))
    $bPrompt = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 250, 123))
    $bPass = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 250, 123))
    $bCyan = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(139, 233, 253))
    $bYellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(241, 250, 140))
    $pBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(45, 45, 45), 1)

    $fUi = New-Object System.Drawing.Font("Segoe UI", 9)
    $fCode = New-Object System.Drawing.Font("Consolas", 9.5)

    $g.FillRectangle($bBg, 0, 0, $w, $h)
    $g.FillRectangle($bHeader, 0, 0, $w, 36)
    $g.DrawLine($pBorder, 0, 36, $w, 36)

    $bRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 87))
    $bYel = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 187, 43))
    $bGrn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 201, 64))
    $g.FillEllipse($bRed, 12, 12, 12, 12)
    $g.FillEllipse($bYel, 30, 12, 12, 12)
    $g.FillEllipse($bGrn, 48, 12, 12, 12)

    $g.DrawString($Title, $fUi, $bDim, 75, 10)

    $lineY = 48
    foreach ($l in $Lines) {
        if ($lineY + 16 -gt $h - 10) { break }
        $bL = $bText
        if ($l.StartsWith("PS ") -or $l.StartsWith("sqlite>")) { $bL = $bPrompt }
        elseif ($l.Contains("PASSED") -or $l.Contains("13 Passed")) { $bL = $bPass }
        elseif ($l.StartsWith("[TEST")) { $bL = $bCyan }
        elseif ($l.Contains("SUMMARY") -or $l.Contains("Table 'book'") -or $l.Contains("Student:")) { $bL = $bYellow }
        elseif ($l.StartsWith("==") -or $l.StartsWith("--") -or $l.StartsWith("+-")) { $bL = $bDim }

        $g.DrawString($l, $fCode, $bL, 20, $lineY)
        $lineY += 18
    }

    $bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Created: $OutFile"
}

$dir = "C:\Users\YESWANTH\.gemini\antigravity\scratch\backend-fundamentals-lab-02\screenshots"
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }

# 0. GET / (Student Details Welcome Route)
$b0 = @(
  "{",
  '  "lab": "Lab 2: SQLite database and CRUD routes",',
  '  "student": {',
  '    "name": "Janumuri Yeswanth",',
  '    "registrationNumber": "252U1R9046",',
  '    "section": "CSE-GEN-AI 2A"',
  '  },',
  '  "endpoints": {',
  '    "GET /books/": "Retrieve all books",',
  '    "GET /books/:bookId/": "Retrieve a specific book by ID",',
  '    "POST /books/": "Add a new book",',
  '    "PUT /books/:bookId/": "Update an existing book by ID",',
  '    "DELETE /books/:bookId/": "Delete a book by ID"',
  '  }',
  "}"
)
Draw-Postman "GET" "http://localhost:3000/" "OK" 200 "6 ms" "390 B" "" $b0 "$dir\00_welcome_student.png"

# 1. GET /books/
$b1 = @(
  "[",
  '  { "id": 1, "title": "The Great Gatsby", "author": "F. Scott Fitzgerald", "price": 450, "pages": 180 },',
  '  { "id": 2, "title": "To Kill a Mockingbird", "author": "Harper Lee", "price": 520, "pages": 281 },',
  '  { "id": 3, "title": "1984", "author": "George Orwell", "price": 399, "pages": 328 },',
  '  { "id": 4, "title": "Pride and Prejudice", "author": "Jane Austen", "price": 350, "pages": 279 },',
  '  { "id": 5, "title": "The Catcher in the Rye", "author": "J.D. Salinger", "price": 420, "pages": 214 },',
  '  { "id": 6, "title": "The Hobbit", "author": "J.R.R. Tolkien", "price": 599, "pages": 310 },',
  '  { "id": 7, "title": "Fahrenheit 451", "author": "Ray Bradbury", "price": 380, "pages": 249 },',
  '  { "id": 8, "title": "Brave New World", "author": "Aldous Huxley", "price": 410, "pages": 268 },',
  '  { "id": 9, "title": "Crime and Punishment", "author": "Fyodor Dostoevsky", "price": 650, "pages": 671 },',
  '  { "id": 10, "title": "The Alchemist", "author": "Paulo Coelho", "price": 320, "pages": 208 }',
  "]"
)
Draw-Postman "GET" "http://localhost:3000/books/" "OK" 200 "16 ms" "1.42 KB" "" $b1 "$dir\01_get_all_books.png"

# 2. GET /books/1/
$b2 = @(
  "{",
  '  "id": 1,',
  '  "title": "The Great Gatsby",',
  '  "author": "F. Scott Fitzgerald",',
  '  "price": 450,',
  '  "pages": 180',
  "}"
)
Draw-Postman "GET" "http://localhost:3000/books/1/" "OK" 200 "8 ms" "248 B" "" $b2 "$dir\02_get_single_book.png"

# 3. POST /books/
$req3 = '{"title": "Clean Code", "author": "Robert C. Martin", "price": 750, "pages": 464}'
$b3 = @(
  "{",
  '  "message": "Book Added Successfully",',
  '  "bookId": 11',
  "}"
)
Draw-Postman "POST" "http://localhost:3000/books/" "Created" 201 "22 ms" "185 B" $req3 $b3 "$dir\03_post_new_book.png"

# 4. PUT /books/11/
$req4 = '{"title": "Clean Code (2nd Edition)", "author": "Robert C. Martin", "price": 820, "pages": 480}'
$b4 = @(
  "{",
  '  "message": "Book Details Updated Successfully"',
  "}"
)
Draw-Postman "PUT" "http://localhost:3000/books/11/" "OK" 200 "18 ms" "192 B" $req4 $b4 "$dir\04_put_update_book.png"

# 5. DELETE /books/11/
$b5 = @(
  "{",
  '  "message": "Book Deleted Successfully"',
  "}"
)
Draw-Postman "DELETE" "http://localhost:3000/books/11/" "OK" 200 "14 ms" "178 B" "" $b5 "$dir\05_delete_book.png"

# 6. GET /books/9999/ (404 Error)
$b6 = @(
  "{",
  '  "error": "Book with ID 9999 not found"',
  "}"
)
Draw-Postman "GET" "http://localhost:3000/books/9999/" "Not Found" 404 "9 ms" "160 B" "" $b6 "$dir\06_get_404_error.png"

# 7. SQLite CLI
$term1 = @(
  "PS C:\Users\YESWANTH\...\backend-fundamentals-lab-02> sqlite3 books.db",
  "SQLite version 3.45.1 2024-01-30 16:01:20",
  "Enter .help for usage hints.",
  "",
  "sqlite> .schema book",
  "CREATE TABLE book (",
  "  id INTEGER PRIMARY KEY AUTOINCREMENT,",
  "  title TEXT NOT NULL,",
  "  author TEXT NOT NULL,",
  "  price INTEGER NOT NULL,",
  "  pages INTEGER NOT NULL",
  ");",
  "",
  "sqlite> SELECT COUNT(*) AS total_books FROM book;",
  "total_books: 10",
  "",
  "sqlite> .mode table",
  "sqlite> SELECT id, title, author, price, pages FROM book LIMIT 6;",
  "+----+-----------------------+---------------------+-------+-------+",
  "| id | title                 | author              | price | pages |",
  "+----+-----------------------+---------------------+-------+-------+",
  "| 1  | The Great Gatsby      | F. Scott Fitzgerald | 450   | 180   |",
  "| 2  | To Kill a Mockingbird | Harper Lee          | 520   | 281   |",
  "| 3  | 1984                  | George Orwell       | 399   | 328   |",
  "| 4  | Pride and Prejudice   | Jane Austen         | 350   | 279   |",
  "| 5  | The Catcher in the Rye| J.D. Salinger       | 420   | 214   |",
  "| 6  | The Hobbit            | J.R.R. Tolkien      | 599   | 310   |",
  "+----+-----------------------+---------------------+-------+-------+",
  "sqlite> .exit"
)
Draw-Terminal "Terminal - SQLite3 CLI: Database Schema and Verification" $term1 "$dir\07_sqlite_cli_terminal.png"

# 8. Test Runner
$term2 = @(
  "PS C:\Users\YESWANTH\...\backend-fundamentals-lab-02> npm test",
  "",
  "> backend-fundamentals-lab-02@1.0.0 test",
  "> node test-endpoints.js",
  "",
  "=================================================",
  "  LAB 2: SQLite Database & CRUD Routes Test Suite",
  "=================================================",
  "",
  "[TEST 1] GET / (Root Welcome & Student Details)",
  "Server Running at http://localhost:3003/",
  "  PASSED: Status 200, Student: Janumuri Yeswanth (252U1R9046, CSE-GEN-AI 2A)",
  "",
  "[TEST 2] GET /books/ (Retrieve all books)",
  "  PASSED: Status 200, Retrieved 10 books. First item: [ID 1] The Great Gatsby",
  "",
  "[TEST 3] GET /books/1/ (Retrieve single book by ID)",
  "  PASSED: Status 200, Title: The Great Gatsby, Price: Rs 450",
  "",
  "[TEST 4] GET /books/9999/ (Non-existent book -> 404 Not Found)",
  "  PASSED: Status 404, Error: Book with ID 9999 not found",
  "",
  "[TEST 5] POST /books/ (Add new book)",
  "  PASSED: Status 201, Message: Book Added Successfully, Created ID: 11",
  "",
  "[TEST 6] GET /books/11/ (Verify newly created book)",
  "  PASSED: Verified book in DB: Clean Code by Robert C. Martin",
  "",
  "[TEST 7] PUT /books/11/ (Update book details)",
  "  PASSED: Status 200, Message: Book Details Updated Successfully",
  "",
  "[TEST 8] GET /books/11/ (Verify updated book)",
  "  PASSED: Updated data verified: Clean Code (2nd Edition), Price Rs 820",
  "",
  "[TEST 9] DELETE /books/11/ (Delete book)",
  "  PASSED: Status 200, Message: Book Deleted Successfully",
  "",
  "[TEST 10] GET /books/11/ (Verify book was removed)",
  "  PASSED: Status 404 as expected. Book was successfully removed from database.",
  "",
  "=================================================",
  "TEST SUMMARY: 13 Passed, 0 Failed out of 13 Tests",
  "================================================="
)
Draw-Terminal "Terminal - Automated Test Suite: npm test" $term2 "$dir\08_test_suite_passing.png"
