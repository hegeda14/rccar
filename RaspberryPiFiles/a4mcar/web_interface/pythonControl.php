<!--
 Script Description:
 	A4MCAR Web Interface, This server page calls python script from PHP
 
 Author:
 	M. Ozcelikors <mozcelikors@gmail.com>, Fachhochschule Dortmund
 
 Disclaimer:
 	Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 	All rights reserved. This program and the accompanying materials are made available under the
 	terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at
 	http://www.eclipse.org/legal/epl-v10.html

 Preliminary Information:
	To enable this: sudo visudo  ,Add this to the end:  "www-data ALL=(ALL) NOPASSWD: ALL"
-->
<?php 
$command = $_GET['process'];
$command = "sudo python /var/www/html/scripts/record_driving_command.py ".$command;
$output = @shell_exec($command); 
?>
