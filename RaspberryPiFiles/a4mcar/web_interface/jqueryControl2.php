<!DOCTYPE html>
<!--
 Script Description:
 	A4MCAR Web Interface, Control page with buttons
 
 Author:
 	M. Ozcelikors <mozcelikors@gmail.com>, Fachhochschule Dortmund
 
 Disclaimer:
 	Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 	All rights reserved. This program and the accompanying materials are made available under the
 	terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at
 	http://www.eclipse.org/legal/epl-v10.html
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><?php echo "A4MCAR: Distributed Multi-core APP4MC Demonstrator Web Interface"; ?></title>
<style type="text/css">
<!--
body{
	height:100%;
	font-family:Arial,'Helvetica Neue',Helvetica,sans-serif;
	margin:0;
	padding:0;
	border:0;
	background: url('images/bsg.jpg') no-repeat center center fixed; 
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
<script type="text/javascript">
var isDown    = false;
var Direction = 50; //0-left, 50-middle 99-right ->for the sake of easement
var Gear      = 'F'; // F (fwd) or R (rev)

$(document).ready(function(){
	 $('#forward_btn').mousedown(function(){
			$.ajax({ 
				url: "pythonControl.php?process=S80A50FE"
			});
			isDown = true;
			Direction = 50;
			Gear = 'F';
	 });
	 
	 //-------------
	 $('#backward_btn').mousedown(function(){
			$.ajax({ 
				url: "pythonControl.php?process=S99A50RE"
			});
			isDown = true;
			Direction = 50;
			Gear = 'R';
	 });
	 
	 //-------------
	 $('#turnleft_btn').mousedown(function(){
			$.ajax({ 
				url: "pythonControl.php?process=S80A00FE"
			});
			isDown = true;
			Direction = 0;
			Gear = 'F';
	 });
	 
	 //-------------
	 $('#turnright_btn').mousedown(function(){
			$.ajax({ 
				url: "pythonControl.php?process=S80A99FE"
			});
			isDown = true;
			Direction = 99;
			Gear = 'F';
	 });
	 
	 //-------------
	 $('#turnbackright_btn').mousedown(function(){
			$.ajax({ 
				url: "pythonControl.php?process=S80A99RE"
			});
			isDown = true;
			Direction = 99;
			Gear = 'R';
	 });
	 
	 //-------------
	 $('#turnbackleft_btn').mousedown(function(){
			$.ajax({ 
				url: "pythonControl.php?process=S80A00RE"
			});
			isDown = true;
			Direction = 0;
			Gear = 'R';
	 });
	 
	 $(document).mouseup(function(){
			if (isDown == true)
			{
				if (Direction == 0)
				{
					if (Gear == 'R')
					{
						$.ajax({ 
							url: "pythonControl.php?process=S00A00RE"
						});
					}
					else //Gear F
					{
						$.ajax({ 
							url: "pythonControl.php?process=S00A00FE"
						});
					}
				}
				else if (Direction == 50)
				{
					if (Gear == 'R')
					{
						$.ajax({ 
							url: "pythonControl.php?process=S00A50RE"
						});
					}
					else //Gear F
					{
						$.ajax({ 
							url: "pythonControl.php?process=S00A50FE"
						});
					}
				}
				else //Direction 99
				{
					if (Gear == 'R')
					{
						$.ajax({ 
							url: "pythonControl.php?process=S00A99RE"
						});
					}
					else //Gear F
					{
						$.ajax({ 
							url: "pythonControl.php?process=S00A99FE"
						});
					}
				}
				isDown = false;	
			}	 
	 });
	 
	 
	 
	 //-------------
	 
	 $('#sensorinfo_btn').click(function(){
	 	$('#sensorSectionDiv').slideToggle(300);
	 });

})

</script>

</head>
<body>
<div id="keyboardInfo"><img src="images/keyboard.png"></div>
<p>&nbsp;</p>
<div id="header" style="align:center; text-align:center;">
  <p><img src="images/logo.png" width="319" height="103"><img src="images/a4mcarlogo.png" width="164" height="95"></p>
</div>
<div id="bilgi">

  <div id="icerik"> 
    <table class="bilgiTable1"   border="0" align="center" cellpadding="0" cellspacing="0">
      <tr>
        <td style="padding:10px;"><div id="div" style="align:center; text-align:center;"> <img  width="640px" height="480px" src="<?php echo "http://".$_SERVER['SERVER_ADDR'].":8081/?action=stream"; ?>" /> </div></td>
        <td style="padding:10px;"><br>
        <p><br>
        </p>
        <p>
          <input type="button" class="buton" id="turnleft_btn"  style="font-size:50px; width:100px; background:url(images/arrow_r1_c6_r1_c1.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " value="" />
          <input type="button"  class="buton"  style="font-size:50px; width:100px;  background:url(images/arrow_r1_c6_r1_c4.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " id="forward_btn" value="" />
          <input  type="button" class="buton" id="turnright_btn" style="font-size:50px; width:100px; background:url(images/arrow_r1_c6_r1_c7.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " value="" />
          <br>
          <input type="button" class="buton" id="turnbackleft_btn"  style="font-size:50px; width:100px; background:url(images/arrow_r1_c6_r3_c1.png) no-repeat  scroll 20px 7px ,url(images/bgbutton.png) repeat-x;" value="" />
          <input type="button"  class="buton"  style="font-size:50px; width:100px;  background:url(images/arrow_r1_c6_r3_c4.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " id="backward_btn" value="" />
          <input  type="button" class="buton" id="turnbackright_btn" style="font-size:50px; width:100px; background:url(images/arrow_r1_c6_r3_c7.png) no-repeat scroll 20px 7px,url(images/bgbutton.png) repeat-x; " value="" />
          <br><br>
          <br>
          
          <input type="button" class="buton" style="width:318px; padding-top:10px; padding-bottom:10px;" id="sensorinfo_btn" value="Show/Hide Core Utilization" /><br>
        </p></td>
      </tr>
    </table>
    <br>
  <div id="sensorSectionDiv" style="display:none;"><table class="bilgiTable"   border="0" align="center" cellpadding="0" cellspacing="0">
    <tr>
      <td style="padding:10px;"><iframe id="sensorSection" height="420px" width="970px" frameborder="0" scrolling="no" src="<?php echo "http://".$_SERVER['SERVER_ADDR']."/utilizationGraph.php"; ?>"></iframe> </td>
      <td style="padding:10px;">
        </td>
    </tr>
    </table></div>
  </div><div align="center"><br>
    <img src="images/logo2.png" width="418" height="53"></div>
</div>

</body>
</html>

