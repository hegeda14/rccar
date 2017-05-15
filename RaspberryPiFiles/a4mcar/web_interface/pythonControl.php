<?php 
// Call python script from PHP
// sudo visudo  ,Add this to the end:  "www-data ALL=(ALL) NOPASSWD: ALL" 
$command = $_GET['process'];
$command = "sudo python /var/www/html/scripts/record_driving_command.py ".$command;

$output = @shell_exec($command); 
?>
