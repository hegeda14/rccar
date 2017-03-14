<?php
$output = @shell_exec("echo raspberry | sudo python /var/www/ultrasonic.py");
$myFile = "sensor_file.inc";
$fh = fopen($myFile, 'w+') or die("can't open file");
$stringData = $output;
fwrite($fh, $stringData);
fclose($fh);
?>

