<?php
function setGPIOmode($pinNumber, $mode){
	if($mode && $pinNumber && (($mode=="out")||($mode=="in")))
		@shell_exec(sprintf("echo raspberry | /usr/local/bin/gpio -g mode %s %s",$pinNumber, $mode));
}
function setGPIOvalue($pinNumber, $value){
	if($value && $pinNumber && (($value=="high")||($value=="low"))){
		if($value == "high") $binaryval = "1";
		else $binaryval = "0";
		@shell_exec(sprintf("echo raspberry | /usr/local/bin/gpio -g write %s %s",$pinNumber, $binaryval));
	}
}
?>