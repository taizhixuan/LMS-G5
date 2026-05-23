<?php
include('dbcon.php');
include('session.php');

function fail($msg) {
    $_SESSION['flash_error'] = $msg;
    header("Location: borrow.php");
    exit;
}

$book_ids  = (isset($_POST['selector']) && is_array($_POST['selector'])) ? array_map('intval', $_POST['selector']) : [];
$member_id = isset($_POST['member_id']) ? (int) $_POST['member_id'] : 0;
$due_date  = isset($_POST['due_date'])  ? trim($_POST['due_date'])  : '';

if (empty($book_ids))                                  fail('Please select at least one book.');
if (count($book_ids) > 3)                              fail('You can borrow at most 3 books per transaction (received ' . count($book_ids) . ').');
if (count($book_ids) !== count(array_unique($book_ids))) fail('Duplicate books in selection are not allowed.');
if ($member_id <= 0)                                   fail('Please select a borrower.');
if ($due_date === '')                                  fail('Due date is required.');

$dt = DateTime::createFromFormat('d/m/Y', $due_date) ?: DateTime::createFromFormat('Y-m-d', $due_date);
if ($dt === false) fail('Due date must be in DD/MM/YYYY format.');
$due_date_sql = $dt->format('Y-m-d');

$stmt = mysqli_prepare($con, "SELECT 1 FROM member WHERE member_id = ?");
mysqli_stmt_bind_param($stmt, 'i', $member_id);
mysqli_stmt_execute($stmt);
mysqli_stmt_store_result($stmt);
if (mysqli_stmt_num_rows($stmt) === 0) {
    mysqli_stmt_close($stmt);
    fail('Member ID ' . $member_id . ' does not exist.');
}
mysqli_stmt_close($stmt);

$placeholders = implode(',', array_fill(0, count($book_ids), '?'));
$types        = str_repeat('i', count($book_ids));
$sql = "SELECT b.book_id,
               b.book_copies,
               b.book_copies - COALESCE(SUM(CASE WHEN bd.borrow_status='pending' THEN 1 ELSE 0 END), 0) AS available
          FROM book b
     LEFT JOIN borrowdetails bd ON bd.book_id = b.book_id
         WHERE b.book_id IN ($placeholders)
      GROUP BY b.book_id, b.book_copies";
$stmt = mysqli_prepare($con, $sql);
mysqli_stmt_bind_param($stmt, $types, ...$book_ids);
mysqli_stmt_execute($stmt);
$res = mysqli_stmt_get_result($stmt);

$found = [];
while ($row = mysqli_fetch_assoc($res)) {
    $bid = (int) $row['book_id'];
    if ((int) $row['available'] <= 0) {
        mysqli_stmt_close($stmt);
        fail('Book ID ' . $bid . ' has no available copies.');
    }
    $found[$bid] = true;
}
mysqli_stmt_close($stmt);

foreach ($book_ids as $bid) {
    if (!isset($found[$bid])) fail('Book ID ' . $bid . ' does not exist.');
}

mysqli_query($con, "INSERT INTO borrow (member_id, date_borrow, due_date) VALUES ($member_id, NOW(), '$due_date_sql')") or die(mysqli_error($con));
$query     = mysqli_query($con, "SELECT * FROM borrow ORDER BY borrow_id DESC") or die(mysqli_error($con));
$row       = mysqli_fetch_array($query);
$borrow_id = (int) $row['borrow_id'];

foreach ($book_ids as $bid) {
    mysqli_query($con, "INSERT INTO borrowdetails (book_id, borrow_id, borrow_status) VALUES ($bid, $borrow_id, 'pending')") or die(mysqli_error($con));
}

header("Location: borrow.php");
exit;
