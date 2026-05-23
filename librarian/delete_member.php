<?php
include('dbcon.php');
$id=$_GET['id'];
mysqli_query($con, "delete from member where member_id='$id'") or die(mysqli_error($con));
header('location:member.php');
?>
