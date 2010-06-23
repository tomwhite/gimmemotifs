<?python
title = "Gimme motifs cluster report"
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns:py="http://purl.org/kid/ns#">
<head>
<title py:content="title"></title>	
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<!--
<link rel="stylesheet" type="text/css" href="style.css" media="screen" /> 
-->

<STYLE type="text/css">
<!--

*{margin:0; padding:0;}

body {
font-family: Verdana, Arial, "Trebuchet MS", Sans-Serif, Georgia, Courier, "Times New Roman", Serif;
font-size: 12px; 
background: #dfdfdf url(images/bg.jpg) repeat-y top center;
color: #333; 
line-height: 135%;
}

a { color: #045A8D; text-decoration: none; }
a:hover { text-decoration: none; color : #7F0000; }

img{ border: none; padding: 6px; } 
img a{border:none;} 

ul { list-style-type: none; }

#page {
width: 1000px;
margin: 0 auto;
}

#header { 
background: #045A8D url(images/header.jpg) no-repeat;
height: 90px;
}
#header h1 {
font-size: 27px;
font-weight: 100;
padding: 16px 0 2px 30px;
}
#header h1 a {
color: #fff;
}
#header h1 a:hover {
color: #BFD5FF;
}
#header h2 {
color: #eee;
font-size: 17px;
font-weight: 100;
padding: 7px 0 0 30px;
}
#wrapper {
padding: 0 20px 0 0;
background: #ffffff;
}

#content {
float: right;
width: 770px;
padding-top: 10px;
padding-bottom: 10px;
background: #ffffff;
}

#sidebar {
float: left;
width: 200px;
padding-bottom: 10px;
background: #ffffff;
}

#footer {
margin: 0 auto 10px auto;
background: #fff url(images/footer.jpg) no-repeat;
height: 50px;
line-height: 50px;
font-weight: 100;
font-size: 12px;
text-align: center;
color: #fff;	
}
#footer p { color: #fff; text-align:right; padding-right: 20px; font-size: 8px;}
#footer a { color: #fff; text-decoration: none; }
#footer a:hover { text-decoration: underline; }

#content th {
color: #0570B0;
}

#content h2 {
font-weight: 100;
font-size: 23px;
margin: 0 0 4px; padding: 10px 0 10px; 
color: #045A8D;
}

#content h3 {
font-weight: 100;
font-size: 18px;
margin: 0 0 4px; padding: 0 0 3px; 
color: #000;
}
#content ul {
color: #555555;
padding: 10px 30px;
}
#content ul li {
list-style-type: square;
}

#sidebar img { padding: 0; margin: 0; }
#sidebar ul {
    list-style-type: none; 
}

#sidebar h2 {
    background: #045A8D;
    height: 30px;
    line-height: 30px;
    font-weight: 600;
    font-size: 13px;
    margin: 10px 0 0 0; padding: 0 0 0 20px; 
    color: #fff;
}

#sidebar ul {
padding: 0px 0 5px 20px;
}

#sidebar p {
	padding: 0px 0 5px 20px;
	font-size: 10px;
	color: #555555;
}
#sidebar ul li {
    padding: 2px 0 2px 2px;
}
#sidebar ul li a { font-size: 12px; font-weight: 600; }

-->
</STYLE>
</head>
<body>

<div id="page">

<div id="header">
<h1><a href="#">GimmeMotifs v${version}</a></h1>
<h2>Cluster report: ${inputfile} (${date})</h2>
</div>

<div id="wrapper">

<div id="content">
<table border="1">
<tr py:for="motif in motifs">
<td py:content="motif[0]"/>
<td>
<img height="80" py:attrs="motif[1]"/>
</td>
<td>
<table>
<tr py:for="m in motif[2]">
<td>
<img height="40" py:attrs="m"/>
</td>
<td py:content='m["alt"]'/>
</tr>
</table>
</td>
</tr>
</table>

</div>

<div id="sidebar"> 

<h2>Result Files</h2>
<ul>
<li><a href="${expname}_motif_report.html">Results</a></li> 
<li><a href="${expname}_motif_report.tsv">Results (.tsv)</a></li> 
<li><a href="${expname}_cluster_report.html">Cluster report</a></li> 
<li><a href="${expname}_motifs.pwm">Weight matrices</a></li>
<li><a href="${expname}_params.txt">Parameters</a></li>
<li><a href="gimme_motifs.log">Log</a></li>
</ul>

<h2>Reference</h2>
<p>Please cite:
<br/>
<a href="http://www.pubmed.org/">van Heeringen, S.J, Manuscript in preparation.</a></p>
</div>

<div style="clear: both;"> </div>
</div>

<div id="footer">
<p></p>
</div>

</div>

		
</body>

</html>
