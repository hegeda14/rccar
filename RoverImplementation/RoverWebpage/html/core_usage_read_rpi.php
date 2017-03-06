<html>
<head>
<meta http-equiv="refresh" content="3" >
<!--[if lt IE 9]><script language="javascript" type="text/javascript" src="jqplot_dist/excanvas.js"></script><![endif]-->
<script language="javascript" type="text/javascript" src="jqplot_dist/jquery.min.js"></script>
<script language="javascript" type="text/javascript" src="jqplot_dist/jquery.jqplot.min.js"></script>
<script language="javascript" type="text/javascript" src="jqplot_dist/plugins/jqplot.barRenderer.min.js"></script>
<script language="javascript" type="text/javascript" src="jqplot_dist/plugins/jqplot.categoryAxisRenderer.js"></script>
<link rel="stylesheet" type="text/css" href="jqplot_dist/jquery.jqplot.css" />
<!-- @author mozcelikors <mozcelikors@gmail.com>, FH Dortmund -->
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
				url : "core_usage_rpi.inc",
				dataType: "text",
				async: false,
				success : function (data) {
					var myString = data;
					var myArray = myString.split(',');
					var averageCore1 = (Math.round(myArray[0])+Math.round(myArray[5])+Math.round(myArray[10])+Math.round(myArray[15]))/4;
					var averageCore2 = (Math.round(myArray[1])+Math.round(myArray[6])+Math.round(myArray[11])+Math.round(myArray[16]))/4;
					var averageCore3 = (Math.round(myArray[2])+Math.round(myArray[7])+Math.round(myArray[12])+Math.round(myArray[17]))/4;
					var averageCore4 = (Math.round(myArray[3])+Math.round(myArray[8])+Math.round(myArray[13])+Math.round(myArray[18]))/4;
					averageSensorReading = Math.round((averageCore1+averageCore2+averageCore3+averageCore4)/4);
 					
					$('#distSensorReading').prepend("<br /><br /><span style=\"font-size:20px; color:#CCC;\">Avg. Util (RaspberryPi)</span><br /><span style=\" font-size:40px; color:#00CCFF;\">"+averageSensorReading+"&nbsp;%</span>");
				        
					
        $.jqplot.config.enablePlugins = true;
        var raspberry = [averageCore1, averageCore2, averageCore3, averageCore4];
        var ticks = ['Core0', 'Core1', 'Core2', 'Core3'];
        var labels = ['Raspberry Pi'];
        plot1 = $.jqplot('chartdiv', [raspberry], {
            // Only animate if we're not using excanvas (not in IE 7 or IE 8)..
            //animate: !$.jqplot.use_excanvas,
            seriesDefaults:{
                renderer:$.jqplot.BarRenderer,
                pointLabels: { show: true }
            },
            legend: {show:true, labels:labels},
	    axes: {
                xaxis: {
                    renderer: $.jqplot.CategoryAxisRenderer,
                    ticks: ticks
                }
            },
            title : 'System Core Utilization',
            highlighter: { show: false },
	    series:[{color:'#0099CC'}, {color:'lightgreen'}, {color:'orange'}]
	    
        });
     
        
   


					
	}
  });
});
</script>
</head>
<body>
<div id="chartdiv" style="height:400px;width:650px; color:white; float:left; margin-right:10px;"></div>
<div id="distSensorReading" style="float:right; height:400px; width:220px; text-align:center;">

</div>
</body>
</html>
