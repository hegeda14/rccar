<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><?php echo "Rover Webpage [Front-end control page]"; ?></title>
<!-- @author mozcelikors <mozcelikors@gmail.com>, FH Dortmund -->
<style type="text/css">
<!--
body{
	height:100%;
	font-family:Arial,'Helvetica Neue',Helvetica,sans-serif;
	margin:0;
	padding:0;
	border:0;
	background: url('images/bsg.jpg') no-repeat center center fixed; /*silinecek*/
	-webkit-background-size: cover;
	-moz-background-size: cover;
	-o-background-size: cover;
	background-size: cover;
}
#icerik {
	width:1020px;
	font-family:Tahoma; 
	font-size:12px; 
	color:#FFF; 
	background-image: url('images/bst.png');
	padding:10px;
	-moz-border-radius:16px;
	-webkit-border-radius:16px;
	border-radius:16px;
	margin:10px auto;
	padding-top:15px;
	padding-bottom:15px;
}
.bilgiTable {
	-moz-border-radius:16px;
	-webkit-border-radius:16px;
	border-radius:16px;
	background-color:#666666;
	
}
.buton {
	-moz-box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	-webkit-box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #bababa), color-stop(1, #9e9e9e) );
	background:-moz-linear-gradient( center top, #bababa 5%, #9e9e9e 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#bababa', endColorstr='#9e9e9e');
	background-color:#bababa;
	-moz-border-radius:6px;
	-webkit-border-radius:6px;
	border-radius:6px;
	border:1px solid #adadad;
	display:inline-block;
	color:#fafafa;
	font-family:arial;
	font-size:15px;
	font-weight:bold;
	padding:6px 24px;
	text-decoration:none;
	text-shadow:1px 1px 0px #808080;
	border:1px solid #CCCCCC;
	margin:2px;
	cursor:pointer;
}.buton:hover {
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #9e9e9e), color-stop(1, #bababa) );
	background:-moz-linear-gradient( center top, #9e9e9e 5%, #bababa 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#9e9e9e', endColorstr='#bababa');
	background-color:#9e9e9e;
}.buton:active {
	position:relative;
	top:1px;
}
.buton1 {	-moz-box-shadow:inset 0px 1px 0px 0px #ffffff;
	-webkit-box-shadow:inset 0px 1px 0px 0px #ffffff;
	box-shadow:inset 0px 1px 0px 0px #ffffff;
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #ededed), color-stop(1, #dfdfdf) );
	background:-moz-linear-gradient( center top, #ededed 5%, #dfdfdf 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ededed', endColorstr='#dfdfdf');
	background-color:#ededed;
	-moz-border-radius:6px;
	-webkit-border-radius:6px;
	border-radius:6px;
	border:1px solid #dcdcdc;
	display:inline-block;
	color:#777777;
	font-family:arial;
	font-size:15px;
	font-weight:bold;
	padding:6px 24px;
	text-decoration:none;
	text-shadow:1px 1px 0px #ffffff;
	cursor:pointer;
	border:1px solid #CCCCCC;
	margin:2px;
}
.buton2 {	-moz-box-shadow:inset 0px 1px 0px 0px #ffffff;
	-webkit-box-shadow:inset 0px 1px 0px 0px #ffffff;
	box-shadow:inset 0px 1px 0px 0px #ffffff;
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #ededed), color-stop(1, #dfdfdf) );
	background:-moz-linear-gradient( center top, #ededed 5%, #dfdfdf 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ededed', endColorstr='#dfdfdf');
	background-color:#ededed;
	-moz-border-radius:6px;
	-webkit-border-radius:6px;
	border-radius:6px;
	border:1px solid #dcdcdc;
	display:inline-block;
	color:#777777;
	font-family:arial;
	font-size:15px;
	font-weight:bold;
	padding:6px 24px;
	text-decoration:none;
	text-shadow:1px 1px 0px #ffffff;
	cursor:pointer;
	border:1px solid #CCCCCC;
	margin:2px;
}
.bilgiTable1 {	-moz-border-radius:16px;
	-webkit-border-radius:16px;
	border-radius:16px;
	background-color:#666666;
}
.buton3 {	-moz-box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	-webkit-box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #bababa), color-stop(1, #9e9e9e) );
	background:-moz-linear-gradient( center top, #bababa 5%, #9e9e9e 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#bababa', endColorstr='#9e9e9e');
	background-color:#bababa;
	-moz-border-radius:6px;
	-webkit-border-radius:6px;
	border-radius:6px;
	border:1px solid #adadad;
	display:inline-block;
	color:#fafafa;
	font-family:arial;
	font-size:15px;
	font-weight:bold;
	padding:6px 24px;
	text-decoration:none;
	text-shadow:1px 1px 0px #808080;
	border:1px solid #CCCCCC;
	margin:2px;
	cursor:pointer;
}
.buton31 {-moz-box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	-webkit-box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	box-shadow:inset 0px 1px 0px 0px #a6a6a6;
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #bababa), color-stop(1, #9e9e9e) );
	background:-moz-linear-gradient( center top, #bababa 5%, #9e9e9e 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#bababa', endColorstr='#9e9e9e');
	background-color:#bababa;
	-moz-border-radius:6px;
	-webkit-border-radius:6px;
	border-radius:6px;
	border:1px solid #adadad;
	display:inline-block;
	color:#fafafa;
	font-family:arial;
	font-size:15px;
	font-weight:bold;
	padding:6px 24px;
	text-decoration:none;
	text-shadow:1px 1px 0px #808080;
	border:1px solid #CCCCCC;
	margin:2px;
	cursor:pointer;
}
#keyboardInfo {
	display:none;
	position: absolute;
    top: 50%;
    left: 50%;
    margin-top: -250px;
    margin-left: -350px;
    width: 700px;
    height: 500px;


}
-->

</style>
<link href="jquery_ui/jquery-ui.css" rel="stylesheet" type="text/css"/>
      <script src="jquery_ui/jquery.min.js"></script>
      <script src="jquery_ui/jquery-ui.min.js"></script>
<!--<script src="jq.js" type="text/javascript" ></script>-->
<script type="text/javascript">

var PREV_OPERATION_MODE = "F";
var _OPERATION_MODE = "F";
/*
	_OPERATION_MODE will function as follows:
	when "F" -> Rover is stopping/breaking.
	when "Q" -> Turn left
	when "W" -> Go forward
	when "E" -> Turn right
	when "A" -> Turn back left
	when "S" -> Go backward
	when "D" -> Turn back right
*/

$(document).keydown(function(event){
	var keycode = (event.keyCode ? event.keyCode : event.which);
	if(keycode == 81){ //Q
		if (_OPERATION_MODE != "Q")
		{
			_OPERATION_MODE = "Q";	
			$.ajax({url: "pythonControl.php?process=Q"});
		}
	}
	if(keycode == 87){ //W
		if (_OPERATION_MODE != "W")
		{
			_OPERATION_MODE = "W";
			$.ajax({url: "pythonControl.php?process=W"});
		}
	}
	if(keycode == 69){ //E
		if (_OPERATION_MODE != "E")
		{
			_OPERATION_MODE = "E";	
			$.ajax({url: "pythonControl.php?process=E"});
		}
	}
	if(keycode == 65){ //A
		if (_OPERATION_MODE != "A")
		{
			_OPERATION_MODE = "A";	
			$.ajax({url: "pythonControl.php?process=A"});
		}
	}
	if(keycode == 83){ //S
		if (_OPERATION_MODE != "S")
		{
			_OPERATION_MODE = "S";	
			$.ajax({url: "pythonControl.php?process=S"});
		}
	}
	if(keycode == 68){ //D
		if (_OPERATION_MODE != "D")
		{
			_OPERATION_MODE = "D";	
			$.ajax({url: "pythonControl.php?process=D"});
		}
	}
	if(keycode == 70){ //F
		if (_OPERATION_MODE != "F")
		{
			_OPERATION_MODE = "F";	
			$.ajax({url: "pythonControl.php?process=F"});
		}
	}
});

$(document).keyup(function(event){
	var keycode = (event.keyCode ? event.keyCode : event.which);
	if(keycode == 81){ //Q
		_OPERATION_MODE = "F";	
		$.ajax({url: "pythonControl.php?process=F"});
	}
	if(keycode == 87){ //W
		_OPERATION_MODE = "F";
		$.ajax({url: "pythonControl.php?process=F"});
	}
	if(keycode == 69){ //E
		_OPERATION_MODE = "F";
		$.ajax({url: "pythonControl.php?process=F"});
	}
	if(keycode == 65){ //A
		_OPERATION_MODE = "F";
		$.ajax({url: "pythonControl.php?process=F"});
	}
	if(keycode == 83){ //S
		_OPERATION_MODE = "F";
		$.ajax({url: "pythonControl.php?process=F"});
	}
	if(keycode == 68){ //D
		_OPERATION_MODE = "F";
		$.ajax({url: "pythonControl.php?process=F"});
	}
	if(keycode == 70){ //F
		_OPERATION_MODE = "F";
		$.ajax({url: "pythonControl.php?process=F"});
	}
});
</script>
<script type="text/javascript">

$(document).ready(function(){
	 $('#forward_btn').mousedown(function(){
			if (_OPERATION_MODE != "W")
			{
				_OPERATION_MODE = "W";	
				$.ajax({url: "pythonControl.php?process=W"});
			}
	 });
	 $('#forward_btn').mouseup(function(){
			_OPERATION_MODE = "F";
			$.ajax({url: "pythonControl.php?process=F"});
	 });
	 //-------------
	 $('#backward_btn').mousedown(function(){
			if (_OPERATION_MODE != "S")
			{
				_OPERATION_MODE = "S";	
				$.ajax({url: "pythonControl.php?process=S"});
			}
	 });
	 $('#backward_btn').mouseup(function(){
			_OPERATION_MODE = "F";
			$.ajax({url: "pythonControl.php?process=F"});
	 });
	 //-------------
	 $('#turnleft_btn').mousedown(function(){
			if (_OPERATION_MODE != "Q")
			{
				_OPERATION_MODE = "Q";	
				$.ajax({url: "pythonControl.php?process=Q"});
			}
	 });
	 $('#turnleft_btn').mouseup(function(){
			_OPERATION_MODE = "F";
			$.ajax({url: "pythonControl.php?process=F"});
	 });
	 //-------------
	 $('#turnright_btn').mousedown(function(){
			if (_OPERATION_MODE != "E")
			{
				_OPERATION_MODE = "E";	
				$.ajax({url: "pythonControl.php?process=E"});
			}
	 });
	 $('#turnright_btn').mouseup(function(){
			_OPERATION_MODE = "F";
			$.ajax({url: "pythonControl.php?process=F"});
	 });
	 //-------------
	 $('#turnbackright_btn').mousedown(function(){
			if (_OPERATION_MODE != "D")
			{
				_OPERATION_MODE = "D";	
				$.ajax({url: "pythonControl.php?process=D"});
			}
	 });
	 $('#turnbackright_btn').mouseup(function(){
			_OPERATION_MODE = "F";
			$.ajax({url: "pythonControl.php?process=F"});
	 });
	 //-------------
	 $('#turnbackleft_btn').mousedown(function(){
			if (_OPERATION_MODE != "A")
			{
				_OPERATION_MODE = "A";
				$.ajax({url: "pythonControl.php?process=A"});	
			}
	 });
	 $('#turnbackleft_btn').mouseup(function(){
			_OPERATION_MODE = "F";
			$.ajax({url: "pythonControl.php?process=F"});
	 });
	 //-------------
	 

	 $('#sensorinfo_btn').click(function(){
	 	$('#sensorSectionDiv').slideToggle(300);
	 });
	 $('#keyboardinfo_btn').click(function(){
	 	$('#keyboardInfo').fadeToggle(300);
	 });
	 $('#keyboardInfo').click(function(){
	 	$('#keyboardInfo').fadeToggle(300);
	 });

	/*if (_OPERATION_MODE == "Q")
	{
		
	}
	else if (_OPERATION_MODE == "W")
	{
		
	}
	else if (_OPERATION_MODE == "E")
	{
		
	}
	else if (_OPERATION_MODE == "A")
	{
		
	}
	else if (_OPERATION_MODE == "S")
	{
		
	}
	else if (_OPERATION_MODE == "D")
	{
		
	}
	else    (_OPERATION_MODE == "F")
	{
		
	}*/
	$.ajax({ 
		url: "pythonControl.php?process="+_OPERATION_MODE
	});


})


</script>

</head>
<body>
<div id="keyboardInfo"><img src="images/kisaltmalar.png"></div>
<p>&nbsp;</p>
<div id="header" style="align:center; text-align:center;">
  <p><img src="images/logo.png" width="400" height="131"></p>
</div>
<div id="bilgi">

  <div id="icerik"> 
    <table class="bilgiTable1"   border="0" align="center" cellpadding="0" cellspacing="0">
      <tr>
        <td style="padding:10px;"><div id="div" style="align:center; text-align:center;"> <img  width="640px" height="480px" src="<?php echo "http://".$_SERVER['SERVER_ADDR'].":8081/?action=stream"; ?>" /> </div></td>
        <td style="padding:10px;"><br>
        <p><br>
        </p>
        <!--
        <table width="100%" height="248" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td width="94%" height="184">
            <input type="button" class="buton" id="fwd_btn"  style="font-size:40px; color:#6FC; width:130px;" value="FWD" />
          <input type="button"  class="buton"  style="font-size:40px; width:130px; color:#FCF;" id="rev_btn" value="REV" /></td>
            <td width="6%"><div id="sliderSpeed"></div></td>
          </tr>
          <tr>
            <td height="64" colspan="2"><div id="sliderDirection"></div></td>
            </tr>
        </table>
        -->
        <p>
          <input type="button" class="buton" id="turnleft_btn"  style="font-size:50px; width:100px; background:url(images/Untitled-2_r1_c6_r1_c1.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " value="" />
          <input type="button"  class="buton"  style="font-size:50px; width:100px;  background:url(images/Untitled-2_r1_c6_r1_c4.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " id="forward_btn" value="" />
          <input  type="button" class="buton" id="turnright_btn" style="font-size:50px; width:100px; background:url(images/Untitled-2_r1_c6_r1_c7.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " value="" />
          <br>
          <input type="button" class="buton" id="turnbackleft_btn"  style="font-size:50px; width:100px; background:url(images/Untitled-2_r1_c6_r3_c1.png) no-repeat  scroll 20px 7px ,url(images/bgbutton.png) repeat-x;" value="" />
          <input type="button"  class="buton"  style="font-size:50px; width:100px;  background:url(images/Untitled-2_r1_c6_r3_c3.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " id="backward_btn" value="" />
          <input  type="button" class="buton" id="turnbackright_btn" style="font-size:50px; width:100px; background:url(images/Untitled-2_r1_c6_r3_c7.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " value="" />
          <br><br>

          <input type="button" class="buton" style="width:318px; padding-top:10px; padding-bottom:10px;" id="sensorinfo_btn" value="Show/Hide Core Utilization" /><br>
          
          <input type="button" class="buton" style="width:318px; padding-top:10px; padding-bottom:10px;" id="keyboardinfo_btn" value="Keyboard Controls" /><br>
        </p></td>
      </tr>
    </table>
    <br>
  <div id="sensorSectionDiv" style="display:none;"><table class="bilgiTable"   border="0" align="center" cellpadding="0" cellspacing="0">
    <tr>
      <td style="padding:10px;"><iframe id="sensorSection" height="420px" width="970px" frameborder="0" scrolling="no" src="<?php echo "http://".$_SERVER['SERVER_ADDR']."/core_usage_read_rpi.php"; ?>"></iframe> </td>
      <td style="padding:10px;">
        </td>
    </tr>
    </table></div>
  </div><div align="center"><br>
    <img src="images/logo2.png" width="418" height="53"></div>
</div>

</body>
</html>

