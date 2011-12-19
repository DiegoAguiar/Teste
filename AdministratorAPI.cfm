<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
Password System</head>
<body>
<cfimage action="captcha" height="100" text="#session.CFID#" width="300">


</body>
</html>
<!---<cfset variables.admin = createObject("component","cfide.adminapi.administrator")>
	<cfset variables.datasource = createObject("component","cfide.adminapi.datasource")>
	<cfdump var="#variables.admin#">
	<cfdump var="#variables.datasource#">--->
