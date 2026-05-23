<?php
include('dbcon.php');
include('session.php');

function bounce($key, $msg) {
    $_SESSION[$key] = $msg;
    header('Location: view_borrow.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    bounce('flash_error', 'Return must be submitted via POST (received ' . $_SERVER['REQUEST_METHOD'] . ').');
}

if (!csrf_check()) {
    bounce('flash_error', 'CSRF token missing or invalid. Please re-open the return dialog and try again.');
}

$borrow_id = isset($_POST['id'])      ? (int) $_POST['id']      : 0;
$book_id   = isset($_POST['book_id']) ? (int) $_POST['book_id'] : 0;

if ($borrow_id <= 0 || $book_id <= 0) {
    bounce('flash_error', 'Invalid borrow_id or book_id.');
}

$stmt = mysqli_prepare($con, "SELECT borrow_details_id, borrow_status FROM borrowdetails WHERE borrow_id = ? AND book_id = ?");
mysqli_stmt_bind_param($stmt, 'ii', $borrow_id, $book_id);
mysqli_stmt_execute($stmt);
$res = mysqli_stmt_get_result($stmt);
$row = mysqli_fetch_assoc($res);
mysqli_stmt_close($stmt);

if ($row === null) {
    bounce('flash_error', "No borrow record found for borrow_id={$borrow_id}, book_id={$book_id}.");
}
if ($row['borrow_status'] !== 'pending') {
    bounce('flash_error', "Cannot return: borrow_details_id={$row['borrow_details_id']} is already '{$row['borrow_status']}'.");
}

$stmt = mysqli_prepare($con, "UPDATE borrowdetails SET borrow_status = 'returned', date_return = NOW() WHERE borrow_details_id = ? AND borrow_status = 'pending'");
mysqli_stmt_bind_param($stmt, 'i', $row['borrow_details_id']);
if (!mysqli_stmt_execute($stmt) || mysqli_stmt_affected_rows($stmt) !== 1) {
    mysqli_stmt_close($stmt);
    bounce('flash_error', 'Return update failed (no row affected). The record may have been returned in another tab.');
}
mysqli_stmt_close($stmt);

bounce('flash_success', "Book ID {$book_id} marked as returned for borrow ID {$borrow_id}.");
