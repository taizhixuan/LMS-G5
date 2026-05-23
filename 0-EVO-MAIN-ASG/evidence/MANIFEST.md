# Evidence Manifest — Group 5 Library Management System Evolution

This index tracks every "before" and "after" artifact captured for
the 6 enhancements (E1–E6). Each row points the report writer at the
exact file that backs a claim in §3 (Code Analysis) or §6 (Testing
and Validation) of the Part II report.

Naming convention: `E<n>_(before|after)_<short_slug>.<ext>`

## Before — captured during Stage 0 (baseline-before-evo) — ✅ COMPLETE

| ID  | Enhancement | File | What it proves | Status |
|-----|-------------|------|----------------|--------|
| E1  | Server-side borrow validation | `before/E1_before_js_bypass_borrowdetails.png` | DevTools tampering wrote 5 rows under `borrow_id=485` (books 15, 17, 18, 19, 20), all `pending` — JS-only 3-book guard bypassed | ✅ captured 2026-05-24 |
| E2  | Transaction-safe borrow saving | `before/E2_before_race_code_borrow_save.png` | Code screenshot of `borrow_save.php` lines 17-20: INSERT + `SELECT ... ORDER BY borrow_id DESC` — race-prone pattern | ✅ captured 2026-05-24 |
| E3  | Schema upgrade | `before/E3_before_schema_show_create.txt` | MyISAM engines, varchar(100) date columns, no FKs; seed data already mixes two date formats | ✅ captured 2026-05-24 |
| E3  | Schema upgrade (visual) | `before/E3_before_schema_phpmyadmin.png` | phpMyAdmin SHOW CREATE TABLE output, formatted for report inclusion | ✅ captured 2026-05-24 |
| E3  | Mixed date formats (visual) | `before/E3_before_mixed_date_formats.png` | `borrow` table SELECT showing `'2014-03-20 23:50:27'` and `'21/03/2014'` in the same varchar columns | ✅ captured 2026-05-24 |
| E4  | Safer return workflow | `before/E4_before_double_return_overwrite.png` | After `GET return_save.php?id=483&book_id=15`: `date_return` was overwritten from original seed value to `2026-05-24 03:03:17` — no status/CSRF/POST check | ✅ captured 2026-05-24 |
| E5  | Efficient book availability | `before/E5_before_n_plus_1_query_log.png` | `mysql.general_log` shows the N+1 query storm from a single `books.php` page load | ✅ captured 2026-05-24 |
| E6  | PHP 8 compatibility | `before/E6_before_php8_fatal_error.html` | curl response from baseline-before-evo `dbcon.php` showing PHP fatal | ✅ captured 2026-05-24 |
| E6  | PHP 8 compatibility (logs) | `before/E6_before_apache_error_log.txt` | Multiple Apache log entries with `Call to undefined function mysql_*` from /librarian/ entry points | ✅ captured 2026-05-24 |
| E6  | PHP 8 compatibility (visual) | `before/E6_before_php8_fatal_browser.png` | Browser screenshot of the fatal error page for the report body | ✅ captured 2026-05-24 |

### Test pollution from defect reproduction

The E1 and E4 captures introduced two contaminated rows in the seed DB:
- `borrow_id = 485` exists with 5 borrowdetails rows (books 15, 17, 18, 19, 20, all `pending`) — created by the E1 bypass.
- `borrow_id = 483 / book_id = 15` now has `date_return = 2026-05-24 03:03:17` instead of the original `2014-03-21 00:30:51` — overwritten by the E4 GET hit.

A `jnv_baseline_polluted.sql` mysqldump should be taken before Stage 1 so we always have a fixed reference of this state, then the pollution should be reverted before Stage 1's E3 migration runs (so the schema migration operates on the canonical seed data and post-migration testing starts from a clean slate).

## After — to be captured during Stages 1–6

| ID  | Enhancement | File | What it will prove | Status |
|-----|-------------|------|--------------------|--------|
| E1  | Server-side borrow validation | `after/E1_after_server_rejects_4books.png` | Same DevTools bypass attempt is rejected by server with flash error | ⏳ pending Stage 2 |
| E2  | Transaction-safe borrow saving | `after/E2_after_atomic_borrow.png` | `borrow_save.php` uses `mysqli_begin_transaction` + `mysqli_insert_id`; concurrent requests no longer mislink | ⏳ pending Stage 3 |
| E3  | Schema upgrade | `after/E3_after_schema_show_create.png` | `SHOW CREATE TABLE` reveals InnoDB, DATETIME columns, foreign keys | ⏳ pending Stage 1 |
| E4  | Safer return workflow | `after/E4_after_get_blocked.png` | GET on `return_save.php` rejected (405 or redirect); POST with invalid borrow_id rejected; CSRF token enforced | ⏳ pending Stage 4 |
| E5  | Efficient book availability | `after/E5_after_single_query_log.png` | general_log shows 1 JOIN query for the same page load | ⏳ pending Stage 5 |
| E6  | PHP 8 compatibility | (covered by the fact that all other "after" screenshots exist) | System runs end-to-end on PHP 8.2 without fatal errors | ✅ implicit |

## Stage status

- Stage 0 — Baseline ✅ in progress (4/6 pieces captured, 4 user actions remaining)
- Stage 1 — E3 schema migration ⏳ blocked on Stage 0 sign-off
- Stages 2–5 — E1, E2, E4, E5 ⏳ blocked on Stage 1
- Stage 6 — Integration + regression ⏳ blocked on Stages 1–5
- Stage 7 — Report + README + SETUP.md ⏳ blocked on Stage 6
- Stage 8 — Presentation deck ⏳ blocked on Stage 7
