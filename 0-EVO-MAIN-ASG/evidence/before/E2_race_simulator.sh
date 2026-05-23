#!/usr/bin/env bash
# Optional race-condition trigger for E2.
# Fires 10 concurrent borrow requests and shows the resulting
# borrowdetails rows. If any borrow_id has the wrong book attached,
# the unsafe ORDER BY borrow_id DESC pattern in borrow_save.php
# misfired and we have a reproduced race.
#
# Requires: curl, mysql CLI, valid session cookie.
#
# Usage:
#   1. Log in to /librarian/ in your browser.
#   2. Open DevTools → Application → Cookies, copy the PHPSESSID value.
#   3. Run: PHPSESSID=xxx ./E2_race_simulator.sh
#
# Note: in practice this often does NOT reproduce on a single-developer
# local XAMPP because requests are serialised by Apache's worker pool
# and MariaDB is too fast. The code-evidence screenshot in
# CAPTURE_SCRIPT.md §E2 is the canonical proof.

set -euo pipefail

: "${PHPSESSID:?Set PHPSESSID=<your session cookie> first}"
URL="http://localhost/Library-Management-System/librarian/borrow_save.php"

# Use distinct (member_id, book_id) pairs per request so a race shows up
# as a mismatched (borrow_id, book_id) row in borrowdetails.
PAIRS=(
  "member_id=52&due_date=30/06/2026&selector%5B%5D=15"
  "member_id=53&due_date=30/06/2026&selector%5B%5D=17"
  "member_id=54&due_date=30/06/2026&selector%5B%5D=18"
  "member_id=55&due_date=30/06/2026&selector%5B%5D=19"
  "member_id=56&due_date=30/06/2026&selector%5B%5D=20"
  "member_id=57&due_date=30/06/2026&selector%5B%5D=21"
  "member_id=58&due_date=30/06/2026&selector%5B%5D=22"
  "member_id=59&due_date=30/06/2026&selector%5B%5D=23"
  "member_id=60&due_date=30/06/2026&selector%5B%5D=24"
  "member_id=62&due_date=30/06/2026&selector%5B%5D=25"
)

echo "Firing ${#PAIRS[@]} concurrent borrow requests..."
for body in "${PAIRS[@]}"; do
  curl -s -o /dev/null -b "PHPSESSID=$PHPSESSID" -d "$body" "$URL" &
done
wait
echo "Done. Inspecting most recent borrowdetails rows..."

"/c/xampp/mysql/bin/mysql.exe" -u root --port=3307 jnv -e "
  SELECT b.borrow_id, b.member_id, bd.book_id, bd.borrow_status
    FROM borrow b
    JOIN borrowdetails bd ON bd.borrow_id = b.borrow_id
   WHERE b.borrow_id > (SELECT MAX(borrow_id) - ${#PAIRS[@]} - 5 FROM borrow)
   ORDER BY b.borrow_id DESC;
"
echo
echo "If any row's (member_id -> book_id) pair does not match the table"
echo "in this script above, the race fired."
