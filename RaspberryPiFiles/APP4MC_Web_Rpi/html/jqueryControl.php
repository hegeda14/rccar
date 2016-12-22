<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><?php echo "APP4MC Powered RC-CAR Demonstrator Webpage"; ?></title>


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
$(document).keypress(function(event){
	var keycode = (event.keyCode ? event.keyCode : event.which);
	if(keycode == 85){ //U
		$.ajax({url: 'pythonControl.php?process=0'});
	}
	if(keycode == 75){ //K
		$.ajax({url: 'pythonControl.php?process=1'});
	}
	if(keycode == 72){ //H
		$.ajax({url: 'pythonControl.php?process=2'});
	}
	if(keycode == 65){ //A
		$.ajax({url: 'pythonControl.php?process=3'});
	}
	if(keycode == 90){ //Z
		$.ajax({url: 'pythonControl.php?process=4'});
	}
	if(keycode == 82){ //R
		$.ajax({url: 'pythonControl.php?process=5'});
	}
	if(keycode == 49){ //1
		$.ajax({url: 'pythonControl.php?process=6'});
	}
	if(keycode == 50){ //2
		$.ajax({url: 'pythonControl.php?process=7'});
	}
	if(keycode == 52){ //4
		$.ajax({url: 'pythonControl.php?process=8'});
	}
	if(keycode == 53){ //5
		$.ajax({url: 'pythonControl.php?process=9'});
	}
	
});

$(document).keyup(function(event){
	var keycode = (event.keyCode ? event.keyCode : event.which);
	if(keycode == 65){ //A
		$.ajax({url: 'pythonControl.php?process=4'});
	}
});
</script>
<script type="text/javascript">
var gear = "F";
$(document).ready(function(){
	 $('#fwd_btn').click(function(){
		gear = "F";
	 	$.ajax({url: 'pythonControl.php?process=S00A00FE'});
	 });
	 $('#rev_btn').click(function(){
		gear = "R";
	 	$.ajax({url: 'pythonControl.php?process=S00A00RE'});
	 });
	 $('#lightson_btn').click(function(){
	 	$.ajax({url: 'pythonControl.php?process=8'});
	 });
	 $('#lightsoff_btn').click(function(){
	 	$.ajax({url: 'pythonControl.php?process=9'});
	 });
	 $('#sensorinfo_btn').click(function(){
	 	$('#sensorSectionDiv').slideToggle(300);
	 });
	 $('#keyboardinfo_btn').click(function(){
	 	$('#keyboardInfo').fadeToggle(300);
	 });
	 $('#keyboardInfo').click(function(){
	 	$('#keyboardInfo').fadeToggle(300);
	 });


	


})


</script>
<script type="text/javascript">
var prevspeed = 0;
var prevdirection = 50;
function refreshSwatch() {
  var speed = $( "#sliderSpeed" ).slider( "value" );
  var direction = $( "#sliderDirection" ).slider( "value" );
  //if (prevspeed != speed || direction != prevdirection){
	$(document).ready(function(){
	  	//$.ajax({url: 'pythonControl.php?process=S'+speed+'A'+direction+gear+'E'});
 
		//$( "body" ).append("S"+speed+"A"+direction+gear);
		if (speed<=9 && direction <=9){
			$.ajax({ 
				url: "pythonControl.php?process=S0"+speed+"A0"+direction+gear+"E"
			});
		}

		if (speed>9 && direction <=9){
                        $.ajax({ 
                                url: "pythonControl.php?process=S"+speed+"A0"+direction+gear+"E"
                        });
                }

		if (speed<=9 && direction > 9){
                        $.ajax({ 
                                url: "pythonControl.php?process=S0"+speed+"A"+direction+gear+"E"
                        });
                }

		if (speed>9 && direction > 9){
                        $.ajax({ 
                                url: "pythonControl.php?process=S"+speed+"A"+direction+gear+"E"
                        });
                }



	});
  //}
  prevspeed = speed;
  prevdirection = direction;
}

$(function(){
	$( "#sliderSpeed" ).slider({
		orientation: "vertical",
		range: "min",
		max: 99,
		value: 0,
		step: 10,
		slide: refreshSwatch,
		change: refreshSwatch
  });
  $( "#sliderDirection" ).slider({
		orientation: "horizontal",
		range: "min",
		value: 50,
		step : 10,
		max: 99,
		slide: refreshSwatch,
		change: refreshSwatch
  });

  $('#sliderSpeed').slider();
  $('#sliderDirection').slider();
});
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
        <td style="padding:10px;"><div id="div" style="align:center; text-align:center;"> <img  width="640px" height="480px" src="http://192.168.1.89:8081/?action=stream" /> </div></td>
        <td style="padding:10px;"><br>
        <p><br>
        </p>
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
        <p>
          <input type="button" class="buton" id="turnright_btn"  style="font-size:50px; width:100px;" value="<" />
          <input type="button"  class="buton"  style="font-size:50px; width:100px;" id="steadystate_btn" value="^" />
          <input  type="button" class="buton" id="turnleft_btn" style="font-size:50px; width:100px;" value=">" />
          <br>
          <input type="button" class="buton" style="width:155px; padding-top:10px; padding-bottom:10px;" id="lightson_btn" value="Lights ON" />
          <input type="button" class="buton" style="width:155px; padding-top:10px; padding-bottom:10px;" id="lightsoff_btn" value="Lights OFF" /><br>
          <input type="button" class="buton" style="width:318px; padding-top:10px; padding-bottom:10px;" id="sensorinfo_btn" value="Show/Hide Core Utilization" /><br>
        </p></td>
      </tr>
    </table>
    <br>
  <div id="sensorSectionDiv" style="display:none;"><table class="bilgiTable"   border="0" align="center" cellpadding="0" cellspacing="0">
    <tr>
      <td style="padding:10px;"><iframe id="sensorSection" height="420px" width="970px" frameborder="0" scrolling="no" src="http://192.168.1.89/core_usage_read_rpi.php"></iframe> </td>
      <td style="padding:10px;">
        </td>
    </tr>
    </table></div>
  </div><div align="center"><br>
    <img src="images/logo2.png" width="418" height="53"></div>
</div>

</body>
</html>

