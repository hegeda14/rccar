<?php 
// PHP'den python script cagirma
// sudo visudo  ,  "www-data ALL=(ALL) NOPASSWD: ALL" eklenmesi gerekiyor
$command = $_GET['process'];
//echo $command;
$command = "sudo python /var/www/html/xmos_command_writetofile.py ".$command;
//echo $command;
$output = @shell_exec($command); 

//$output;
?>
