# Before-Evidence Capture Script — E1, E2, E4, E5

E3 and E6 evidence is **already captured** (text files in this folder).
You can optionally add browser screenshots for E3/E6 if you want pretty
images for the report, but the text captures are sufficient proof.

Save all screenshots into this folder
(`0-EVO-MAIN-ASG/evidence/before/`) using the file names listed under
each section.

Prerequisites:
- XAMPP running, you're on branch `feat/E6-php8-mysqli`
- Browser: Chrome with DevTools available
- Login: `admin` / `admin` at `http://localhost/Library-Management-System/librarian/`

---

## E1 — JS-only 3-book limit can be bypassed

**Save as:** `E1_before_js_bypass_borrowdetails.png`

**What it proves:** the 3-book rule is enforced only in browser JS
(`borrow.php` line 94 `max = 3`), so a user who tampers with the
client can write an arbitrary number of `borrowdetails` rows.

1. Log in to the librarian section.
2. Click **Borrow** in the top nav (or open
   `http://localhost/Library-Management-System/librarian/borrow.php`).
3. Pick any member from the dropdown (e.g. *Mark Sanchez*) and type
   a due date like `30/06/2026`.
4. Tick **3** book checkboxes — note that the 4th onward becomes
   disabled and a popup appears (this is the JS guard we're bypassing).
5. Open DevTools (F12), go to **Console** tab.
6. Paste and run:
   ```js
   $(".uniform_on").removeAttr('disabled').prop('disabled', false);
   ```
7. Tick **2 more book checkboxes** (so you now have 5 selected).
8. Click the **Borrow** button.
9. The page redirects back to borrow.php — no error shown.
10. Open phpMyAdmin → database **jnv** → table **borrowdetails** →
    SQL tab. Run:
    ```sql
    SELECT * FROM borrowdetails
    WHERE borrow_id = (SELECT MAX(borrow_id) FROM borrow);
    ```
11. **Screenshot** the result grid. It will show **5 rows** with the
    same `borrow_id` — invalid record that bypassed the 3-book rule.

---

## E2 — Race-prone borrow_id retrieval (code evidence)

**Save as:** `E2_before_race_code_borrow_save.png`

**What it proves:** `borrow_save.php` lines 17-20 insert into `borrow`
then use `SELECT * FROM borrow ORDER BY borrow_id DESC` to find the
just-inserted row. Under concurrent traffic, the `SELECT` can return
a *different user's* row, attaching the wrong member's book selections
to the wrong borrow header. The race is intermittent and hard to
trigger on demand, so the standard "before" evidence is the code
itself (this is also how the proposal Table 1.1 cites it).

1. Open VS Code (or Notepad++, or any editor with syntax highlighting).
2. Open `C:\xampp\htdocs\Library-Management-System\librarian\borrow_save.php`.
3. Highlight lines **17 to 20**:
   ```php
   mysqli_query($con, "insert into borrow (...) values (...)") or die(...);
   $query = mysqli_query($con, "select * from borrow order by borrow_id DESC") or die(...);
   $row = mysqli_fetch_array($query);
   $borrow_id = $row['borrow_id'];
   ```
4. **Screenshot** the editor with those lines highlighted and the
   file name + line numbers visible.

*(Optional bonus: run the bash snippet in `E2_race_simulator.sh`
in this folder — it fires 10 parallel borrow requests via curl.
If you observe any `borrowdetails` row whose `book_id` doesn't match
what you sent, that's a hit. In practice the local XAMPP install is
often fast enough that the race doesn't fire — don't waste time
chasing it.)*

---

## E3 — Schema flaws (already captured)

**Captured in:** `E3_before_schema_show_create.txt` (already in this folder)

For a visual companion screenshot:
1. Open phpMyAdmin → database **jnv** → table **borrow** → tab **Operations** OR run in SQL tab:
   ```sql
   SHOW CREATE TABLE borrow;
   SHOW CREATE TABLE borrowdetails;
   ```
2. **Screenshot** the result, save as `E3_before_schema_phpmyadmin.png`.
3. Then run:
   ```sql
   SELECT borrow_id, member_id, date_borrow, due_date FROM borrow
   ORDER BY borrow_id DESC LIMIT 5;
   ```
4. **Screenshot** the result (shows mixed `2014-03-20 23:50:27` vs
   `21/03/2014` formats in the same columns), save as
   `E3_before_mixed_date_formats.png`.

---

## E4 — Unvalidated GET-driven return overwrites a returned row

**Save as:** `E4_before_double_return_overwrite.png`

**What it proves:** `return_save.php` accepts `id` and `book_id` from
the URL, runs an UPDATE with **no validation** that (a) the borrow
record exists, (b) the row's `borrow_status` is `pending`, or
(c) the request came via POST/CSRF. So an already-returned row can
be "returned" again, overwriting the original `date_return`.

Demo target: `borrow_id=483` is already returned (`date_return =
2014-03-21 00:30:51`).

1. In phpMyAdmin → SQL tab, run:
   ```sql
   SELECT * FROM borrowdetails WHERE borrow_id = 483;
   ```
   Note the existing `date_return = 2014-03-21 00:30:51`.
2. While logged in as admin in another tab, paste this URL into
   the browser address bar:
   ```
   http://localhost/Library-Management-System/librarian/return_save.php?id=483&book_id=15
   ```
3. The browser silently redirects to `view_borrow.php` — no error,
   no confirmation, no validation.
4. Re-run the SQL from step 1.
5. **Screenshot** the phpMyAdmin result showing the new
   `date_return` is *today's* date — proving the original return
   timestamp was overwritten by an unauthenticated GET.

---

## E5 — N+1 query pattern on books.php

**Save as:** `E5_before_n_plus_1_query_log.png`

**What it proves:** `books.php` lines 55-70 run one outer query
(`SELECT * FROM book`) and then *two* extra queries inside the loop
(one for `borrowdetails`, one for `category`), giving roughly
`2N + 1` queries per page load instead of one JOIN.

1. Open phpMyAdmin → SQL tab. Run:
   ```sql
   SET GLOBAL general_log = 'ON';
   SET GLOBAL log_output  = 'TABLE';
   TRUNCATE TABLE mysql.general_log;
   ```
2. In the browser (logged in as admin), navigate to
   `http://localhost/Library-Management-System/librarian/books.php`
   and let it fully load.
3. Back in phpMyAdmin SQL tab:
   ```sql
   SELECT event_time, argument
     FROM mysql.general_log
    WHERE argument LIKE '%book%'
       OR argument LIKE '%borrowdetails%'
       OR argument LIKE '%category%'
    ORDER BY event_time;
   SELECT COUNT(*) AS total_queries FROM mysql.general_log
    WHERE command_type = 'Query';
   ```
4. **Screenshot** showing the long list of repeated
   `SELECT * FROM borrowdetails WHERE book_id = '<n>'` queries and
   the total count (should be ~60+ for 30 books).
5. Turn the log back off:
   ```sql
   SET GLOBAL general_log = 'OFF';
   ```

---

## E6 — PHP 8 fatal error on baseline (already captured)

**Captured in:**
- `E6_before_php8_fatal_error.html`
- `E6_before_apache_error_log.txt`

For a visual companion screenshot (recommended for the report):
1. In a terminal:
   ```bash
   git checkout baseline-before-evo
   ```
2. In Chrome, hard-reload (Ctrl+Shift+R) this URL:
   `http://localhost/Library-Management-System/dbcon.php`
3. You'll see a stark `Fatal error: Uncaught Error: Call to undefined
   function mysql_select_db()` page.
4. **Screenshot** the whole browser window, save as
   `E6_before_php8_fatal_browser.png`.
5. Return to E6 branch:
   ```bash
   git checkout feat/E6-php8-mysqli
   ```

---

## When you're done

Save all PNGs into this folder, then reply "evidence captured" so the
manifest can be finalised and we can start Stage 1 (E3 — schema
migration first, per the dependency ordering).
