-- =====================================================================
-- Migration: 001_schema_upgrade.sql
-- Enhancement: E3 — Schema upgrade (perfective maintenance)
-- Author: Group 5 (CSE6364, Term 2610)
-- Date:   2026-05-24
-- =====================================================================
-- Purpose:
--   Bring the borrow + borrowdetails tables from MyISAM/varchar(date)
--   state up to a referentially consistent InnoDB schema with proper
--   DATE/DATETIME columns and foreign keys. Required as foundation for
--   enhancements E1 (server-side validation), E2 (transaction-safe save),
--   E4 (safer returns), and E5 (efficient availability JOIN).
--
-- Pre-flight:
--   - Take mysqldump first (see cse6364/migrations/backups/).
--   - Dry-run on jnv_test (CREATE DATABASE jnv_test; source dump; source
--     this file). Only apply to jnv after dry-run succeeds.
--
-- Rollback:
--   Restore the dump in backups/jnv_clean_2026-05-24.sql via:
--     mysql -u root --port=3307 jnv < jnv_clean_2026-05-24.sql
--   (no in-place down-migration is provided — the varchar→DATETIME
--   conversion is lossy in the date_return = '' case).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Section 1 — Pre-normalize string dates so type changes don't fail
-- ---------------------------------------------------------------------
-- borrow.due_date is mixed format. Seed data has '21/03/2014' style.
-- Normalize DD/MM/YYYY -> YYYY-MM-DD while still varchar, so the
-- subsequent MODIFY COLUMN to DATE succeeds without lossy implicit
-- conversion.
UPDATE borrow
   SET due_date = DATE_FORMAT(STR_TO_DATE(due_date, '%d/%m/%Y'), '%Y-%m-%d')
 WHERE due_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';

-- borrow.date_borrow seed values are already '2014-03-20 23:50:27'
-- style — directly castable. No UPDATE needed.

-- borrowdetails.date_return is NOT NULL varchar with '' for pending
-- rows. Allow NULL first, then null out the empty strings, so the
-- subsequent MODIFY COLUMN to DATETIME NULL works cleanly.
ALTER TABLE borrowdetails
  MODIFY COLUMN date_return varchar(100) NULL;

UPDATE borrowdetails
   SET date_return = NULL
 WHERE date_return = '' OR date_return IS NULL;

-- ---------------------------------------------------------------------
-- Section 2 — Convert column types
-- ---------------------------------------------------------------------
ALTER TABLE borrow
  MODIFY COLUMN date_borrow DATETIME    NOT NULL,
  MODIFY COLUMN due_date    DATE        NULL;

ALTER TABLE borrowdetails
  MODIFY COLUMN date_return DATETIME    NULL;

-- ---------------------------------------------------------------------
-- Section 3 — Align borrow.member_id type with member.member_id
-- ---------------------------------------------------------------------
-- Upstream defined borrow.member_id as BIGINT(50) but member.member_id
-- is INT(11). Foreign keys require matching base types — align them.
-- Max actual member_id in seed data is 65, so INT range is plenty.
ALTER TABLE borrow
  MODIFY COLUMN member_id INT NOT NULL;

-- ---------------------------------------------------------------------
-- Section 4 — Convert MyISAM tables to InnoDB
-- ---------------------------------------------------------------------
-- book, member, users, lost_book are already InnoDB (no-op here).
ALTER TABLE borrow        ENGINE = InnoDB;
ALTER TABLE borrowdetails ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Section 5 — Add foreign keys (ON DELETE RESTRICT)
-- ---------------------------------------------------------------------
-- RESTRICT chosen so the DB blocks deletion of a member/book that
-- still has borrow history. Borrow history is intentionally durable;
-- librarians should archive rather than delete.

ALTER TABLE borrow
  ADD CONSTRAINT fk_borrow_member
      FOREIGN KEY (member_id) REFERENCES member(member_id)
      ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE borrowdetails
  ADD CONSTRAINT fk_borrowdetails_borrow
      FOREIGN KEY (borrow_id) REFERENCES borrow(borrow_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT fk_borrowdetails_book
      FOREIGN KEY (book_id)   REFERENCES book(book_id)
      ON DELETE RESTRICT ON UPDATE CASCADE;

-- ---------------------------------------------------------------------
-- Section 6 — Verification queries (read-only, safe to re-run)
-- ---------------------------------------------------------------------
-- After this script completes, run these in phpMyAdmin / mysql CLI
-- to confirm the migration applied correctly:
--
--   SHOW CREATE TABLE borrow\G
--   SHOW CREATE TABLE borrowdetails\G
--   SELECT borrow_id, member_id, date_borrow, due_date FROM borrow ORDER BY borrow_id DESC LIMIT 5;
--   SELECT borrow_details_id, book_id, borrow_id, borrow_status, date_return FROM borrowdetails ORDER BY borrow_details_id DESC LIMIT 5;
