<!-- A4MCAR Web Interface, This server page calls python script from PHP -->
<!-- Author: M.Ozcelikors, Fachhochschule Dortmund <mozcelikors@gmail.com> -->
<!-- To enable this: sudo visudo  ,Add this to the end:  "www-data ALL=(ALL) NOPASSWD: ALL"  -->
<?php 
$command = $_GET['process'];
$command = "sudo python /var/www/html/scripts/record_driving_command.py ".$command;
$output = @shell_exec($command); 
?>
