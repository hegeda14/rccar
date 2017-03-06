<!-- @author mozcelikors <mozcelikors@gmail.com>, FH Dortmund -->
<?php 
// PHP python script calling.
// sudo visudo  ,  "www-data ALL=(ALL) NOPASSWD: ALL" should be added
$command = $_GET['process'];
//echo $command;
$command = "sudo python /var/www/html/rovercommand_writetofile.py ".$command;
echo $command;
$output = @shell_exec($command); 

$output;
echo $output;
?>
