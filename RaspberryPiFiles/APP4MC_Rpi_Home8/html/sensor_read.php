<html>
<head>
<meta http-equiv="refresh" content="3" >
<!--[if lt IE 9]><script language="javascript" type="text/javascript" src="jqplot_dist/excanvas.js"></script><![endif]-->
<script language="javascript" type="text/javascript" src="jqplot_dist/jquery.min.js"></script>
<script language="javascript" type="text/javascript" src="jqplot_dist/jquery.jqplot.min.js"></script>
<link rel="stylesheet" type="text/css" href="jqplot_dist/jquery.jqplot.css" />
<style type="text/css">
   #distSensorReading {
	font-family: Arial, Verdana, 'Trebuchet MS'; 
	display:block;
	font-weight:bold;
   }
   #dist {
   color: #666666;
   font-size:25px;
   }
   #distVal {
   color: #009933;
   font-size:30px;
   }


</style>
<script type="text/javascript">
	$(document).ready(function(){
		$.ajax({
				url : "sensor_file.inc",
				dataType: "text",
				success : function (data) {
					var myString = data;
					var myArray = myString.split(',');
					var averageSensorReading = (Math.round(myArray[0])+Math.round(myArray[2])+Math.round(myArray[4])+Math.round(myArray[6]))/4;
					averageSensorReading = averageSensorReading.toString();
 					$('#distSensorReading').prepend("<br /><br /><br /><br /><br /><br /><span style=\"font-size:20px; color:#CCC;\">Average Distance:</span><br /><span style=\" font-size:40px; color:#00CCFF;\">"+averageSensorReading+"&nbsp;cm</span>");
				        //$('body').html(Math.round(myArray[0])+","+Math.round(myArray[2])+","+Math.round(myArray[4])+","+Math.round(myArray[6]));
                                     	$.jqplot('chartdiv',  [[
					[Math.round(myArray[1]), Math.round(myArray[0])],
					[Math.round(myArray[3]), Math.round(myArray[2])],
					[Math.round(myArray[5]), Math.round(myArray[4])],
					[Math.round(myArray[7]), Math.round(myArray[6])]
					]],
					{ title:'Distance over Time',
					  axes:{yaxis:{min:0, max:30}, xaxis:{min:Math.floor(myArray[1])-0.01 , max:Math.ceil(myArray[7])+1}},
					  series:[{color:'#0099CC'}]
					});
					}
			});
		/*$.ajax({
			url : "sensor_write.php",
			dataType: "text",
			success: function (data2){
				var myString2 = data2;
				$('#distSensorReading').append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span id=\"dist\">Distance: </span><span id=\"distVal\">" + Math.round(myString2*100)/100 + " cm" + "</span>");
			}
		});*/
	});
</script>
</head>
<body>
<div id="chartdiv" style="height:400px;width:650px; color:white; float:left; margin-right:10px;"></div>
<div id="distSensorReading" style="float:right; height:400px; width:220px; text-align:center;">

</div>
</body>
</html>
