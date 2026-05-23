<?php
include('dbcon.php');

$id=$_GET['id'];

mysqli_query($con, "delete from users where user_id='$id'") or die(mysqli_error($con));

header('location:users.php');
?>
