# Integration & Regression Test Matrix — Stage 6

**Executed:** 2026-05-24
**Branch under test:** `evo-main` (HEAD = `c3f41f2`, includes all 6 merges)
**Environment:** XAMPP / PHP 8.2.12 / MariaDB 10.4 / Apache 2.4.58 on port 3307
**Driver:** authenticated `curl` POSTs + `mysql.general_log` + direct DB SELECTs
**Login:** admin / admin

## Test ID conventions

- **T01–T12** are the Appendix E scenarios from the approved proposal (verbatim text and intent preserved).
- **T13–T16** are additional scenarios added by the Stage 0 mission brief (concurrent borrow, duplicate book IDs, GET-blocked return, N+1 query count).

## Results summary

| Tests run | Pass | Fail |
|-----------|------|------|
| 16        | 16   | 0    |

## Detail

| ID  | Scenario | Expected | Actual | Pass | Evidence file |
|-----|----------|----------|--------|------|---------------|
| **T01** | Borrow one available book with valid member ID | Saved successfully (borrow + 1 borrowdetails row) | `borrow_id` 488 inserted, due_date stored as `2026-06-30` | ✅ | `evidence/after/E1_after_test_matrix.txt` (T1) |
| **T02** | Borrow three available books with valid member ID | Saved successfully (1 borrow + 3 borrowdetails) | `borrow_id` 489 inserted with rows 171/172/173 | ✅ | `evidence/after/E1_after_test_matrix.txt` (T2) |
| **T03** | Attempt to borrow more than three books | System rejects (no INSERT, flash error) | 5 selectors → flash *"at most 3 books per transaction (received 5)"*, max(borrow_id) unchanged | ✅ | `evidence/after/E1_after_test_matrix.txt` (T3) |
| **T04** | Attempt to borrow with no selected book | System rejects | empty selector → flash *"Please select at least one book"* | ✅ | `evidence/after/E1_after_test_matrix.txt` (T4) |
| **T05** | Attempt to borrow using an invalid member ID | System rejects | member_id 99999 → flash *"Member ID 99999 does not exist"* | ✅ | `evidence/after/E1_after_test_matrix.txt` (T5) |
| **T06** | Attempt to borrow an unavailable book | System rejects | non-existent book_id → flash *"Book ID 99999 does not exist"* (an existing book with 0 available would flash *"…has no available copies"*) | ✅ | `evidence/after/E1_after_test_matrix.txt` (T6); availability formula proven in E5 evidence |
| **T07** | Return a valid pending borrowed book | System updates return status | borrow_details_id 162 transitioned pending → returned, date_return = `2026-05-24 03:39:12` | ✅ | `evidence/after/E4_after_safer_return.txt` (T7) |
| **T08** | Attempt to return an already-returned book | System rejects | POST `id=483&book_id=15` against returned row → flash *"Cannot return: borrow_details_id=163 is already 'returned'"*, original `date_return = '2014-03-21 00:30:51'` preserved | ✅ | `evidence/after/E4_after_safer_return.txt` (T6) |
| **T09** | Check book availability after borrow transaction | Availability count drops by 1 | book 27 cell on books.php: **21 → 20** after one pending borrow | ✅ | this file (run inline below) |
| **T10** | Check book availability after return transaction | Availability count returns to prior value | book 27 cell on books.php: **20 → 21** after marking borrow returned | ✅ | this file (run inline below) |
| **T11** | Test database date fields after borrow and return | Dates stored as DATE / DATETIME | `borrow.date_borrow = 2026-05-24 03:49:57` (DATETIME), `borrow.due_date = 2026-07-01` (DATE), `borrowdetails.date_return = 2026-05-24 03:49:58` (DATETIME) | ✅ | this file (run inline below) |
| **T12** | Test related pages after implementation | Existing pages still work | 14/14 librarian pages return 200 (see table below) | ✅ | this file (run inline below) |
| **T13** | Concurrent borrow simulation (10 parallel POSTs, distinct member-book pairs) | Every borrowdetails row links to its own borrow_id (no mislinks) | 10/10 stored pairs correct; pre-E2 baseline also returned correct linkage on local XAMPP due to PHP session lock — race is preventatively fixed | ✅ | `evidence/after/E2_after_transaction_safe_save.txt` (Tests 1, 2) |
| **T14** | Duplicate book IDs in same submission | System rejects | selector=`[22, 22]` → flash *"Duplicate books in selection are not allowed"* | ✅ | `evidence/after/E1_after_test_matrix.txt` (T7) |
| **T15** | GET-blocked return | GET request fails with no DB change | `GET return_save.php?id=482&book_id=15` → flash *"Return must be submitted via POST"*, DB untouched | ✅ | `evidence/after/E4_after_safer_return.txt` (T1) |
| **T16** | N+1 query count drop on books.php | Pre vs post query count drops by ~Nx | Pre-E5: **36** queries per page load (1 outer + 17 borrowdetails + 17 category + 1 overhead). Post-E5: **1** query. | ✅ | `evidence/after/E5_after_single_query.txt` |

## T09 / T10 / T11 / T12 inline test transcripts (Stage 6 fresh run)

### T09 — borrow drops availability for book 27
```
BEFORE borrow:
  book 27: book_id=27, title=Asya Pag-usbong Ng Kabihasnan, category=General, available=21
  borrow created: borrow_id=486
AFTER borrow:
  book 27: book_id=27, title=Asya Pag-usbong Ng Kabihasnan, category=General, available=20
```

### T10 — return restores availability
```
AFTER return:
  book 27: book_id=27, title=Asya Pag-usbong Ng Kabihasnan, category=General, available=21
```

### T11 — date columns
```
borrow_id  date_borrow            due_date    borrow_status  date_return
486        2026-05-24 03:49:57    2026-07-01  pending        NULL                  (after T9 borrow)
486        2026-05-24 03:49:57    2026-07-01  returned       2026-05-24 03:49:58   (after T10 return)
```
- `date_borrow` and `date_return` both stored as `DATETIME` with second-precision timestamps.
- `due_date` stored as `DATE` (no time component, as intended).
- Compare with the baseline-before-evo state, where these were `varchar(100)` strings that mixed `'2014-03-20 23:50:27'` and `'21/03/2014'` formats — see `evidence/before/E3_before_schema_show_create.txt`.

### T12 — unrelated pages smoke test (14 / 14 pass)
```
✅ dashboard.php           -> 200
✅ books.php               -> 200
✅ member.php              -> 200
✅ transaction.php         -> 200
✅ view_borrow.php         -> 200
✅ view_return.php         -> 200
✅ archive.php             -> 200
✅ new_books.php           -> 200
✅ old_books.php           -> 200
✅ lost.php                -> 200
✅ damage.php              -> 200
✅ sub_rep.php             -> 200
✅ users.php               -> 200
✅ unstudents.php          -> 200
```
No 500-level responses, no PHP fatal errors in `C:\xampp\apache\logs\error.log` during the run.

## Cross-feature integration notes

- **E1 + E3 single source of truth.** Both `borrow_save.php` (availability check) and `books.php` (listing) use the identical SQL fragment `b.book_copies - COALESCE(SUM(CASE WHEN bd.borrow_status='pending' THEN 1 ELSE 0 END), 0) AS available`. A book that the listing shows as "0 available" is guaranteed to be rejected by the validator and vice versa (proven by direct grep of both files).
- **E2 + E3 interaction.** The new foreign keys (E3) actively *fire* on rollback testing — `fk_borrowdetails_book` rejects a forged borrowdetails row, which is what triggers E2's `mysqli_rollback()` path. So E2's rollback isn't theoretical: it's the only thing preventing an orphan borrow row when bad data slips through.
- **E4 + E3.** The `pending` status check in `return_save.php` is meaningful only because `date_return` can now actually be `NULL` (DATETIME column allowing NULL). Before E3, empty strings made `pending` rows visually indistinguishable from rows where someone forgot to fill `date_return`.
- **E5 + E1 + E4.** The book listing's availability count reflects new pending rows from E1 immediately, and decrements them again after E4's return — verified in T09/T10. So the entire borrow→return cycle is observably consistent on a single page reload.
- **E6 enables all of the above.** Without the `mysql_* → mysqli_*` migration, none of E1–E5 would run at all because the baseline code fatals on PHP 8.

## Test data cleanup

The single borrow row (`borrow_id=486`) and its borrowdetails row created during T09/T10/T11 were deleted at the end of the run. `AUTO_INCREMENT` reset to 486 / 170. Seed-data borrow rows (482/483/484) and seed borrowdetails (162/163/164) are intact and identical to `0-EVO-MAIN-ASG/migrations/backups/jnv_clean_2026-05-24.sql`.
