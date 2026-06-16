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

### Test pollution from defect reproduction (resolved during Stage 1)

The E1 and E4 captures introduced two contaminated rows in the seed DB:
- `borrow_id = 485` with 5 borrowdetails rows (books 15, 17, 18, 19, 20) — created by the E1 bypass.
- `borrow_id = 483 / book_id = 15` `date_return = 2026-05-24 03:03:17` instead of `2014-03-21 00:30:51` — overwritten by the E4 GET hit.

Both states were captured to `migrations/backups/jnv_polluted_2026-05-24.sql` and then reverted to the canonical seed before the E3 schema migration ran. `migrations/backups/jnv_clean_2026-05-24.sql` is the post-cleanup reference dump.

## After — captured during Stages 1–5 — ✅ COMPLETE

| ID  | Enhancement | File | What it proves | Status |
|-----|-------------|------|----------------|--------|
| E1  | Server-side borrow validation | `after/E1_after_test_matrix.txt` | All 4 rejection rules + happy paths verified via curl POSTs that bypass the JS guard entirely; due_date stored as proper DATE | ✅ captured 2026-05-24 |
| E2  | Transaction-safe borrow saving | `after/E2_after_transaction_safe_save.txt` | Pre/post race tests + DB-level and PHP-level forced-failure rollback proofs + E1 regression matrix re-run clean | ✅ captured 2026-05-24 |
| E3  | Schema upgrade | `after/E3_after_schema_show_create.txt` | SHOW CREATE returns InnoDB + DATETIME/DATE + 3 foreign keys; seed dates correctly converted | ✅ captured 2026-05-24 |
| E3  | Schema upgrade — FK enforcement | `after/E3_after_fk_enforcement.txt` | `DELETE FROM member WHERE id=52` now returns ERROR 1451 — FK actively blocks orphan creation | ✅ captured 2026-05-24 |
| E4  | Safer return workflow | `after/E4_after_safer_return.txt` | 7-case matrix: GET / no-CSRF / bad-CSRF / bad-IDs / already-returned all rejected; happy POST stores proper DATETIME | ✅ captured 2026-05-24 |
| E5  | Efficient book availability | `after/E5_after_single_query.txt` | 36 → 1 queries per books.php load; zero rendered-HTML diff; all 17 cell values cross-check against DB | ✅ captured 2026-05-24 |
| E6  | PHP 8 compatibility | (implicit) | All of the above ran on PHP 8.2 — the migration is what allows any of the other after-tests to execute | ✅ implicit |

## Stage 6 — Integration & regression — ✅ COMPLETE

See `testing/test-matrix.md` for the consolidated 16-test matrix
(T01–T16: proposal Appendix E + brief-added concurrent / CSRF / N+1 cases). All 16 cases pass.

## Stage status

- Stage 0 — Baseline ✅ complete
- Stage 1 — E3 schema migration ✅ complete
- Stage 2 — E1 server-side validation ✅ complete
- Stage 3 — E2 transaction-safe saving ✅ complete
- Stage 4 — E4 safer return ✅ complete
- Stage 5 — E5 efficient availability ✅ complete
- Stage 6 — Integration + regression ✅ complete
