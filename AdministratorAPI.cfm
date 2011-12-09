<html>
<head>Password System</head>
<body>
<cfimage action="captcha" height="100" text="#session.CFID#" width="300">


</body>
</html>
<!---<cfset variables.admin = createObject("component","cfide.adminapi.administrator")>
	<cfset variables.datasource = createObject("component","cfide.adminapi.datasource")>
	<cfdump var="#variables.admin#">
	<cfdump var="#variables.datasource#">--->


<cfquery name="testeSamir" datasource="cfartgallery">
Select *
From app.Artists
Where State in (<cfqueryparam cfsqltype="cf_sql_varchar" list="yes" separator="," value="CA,FL,DC"/>)
</cfquery>

<cfset NewQuerySamir=QueryNew("address,artistid,city,email,fax,firstname,lastname,phone,postalcode,state,thepassword,countgeral")>
<cfloop query="testeSamir">
	<cfset QueryAddRow(NewQuerySamir)>
    <cfset QuerySetCell(NewQuerySamir,"address",testeSamir.ADDRESS)>
    <cfset QuerySetCell(NewQuerySamir,"artistid",testeSamir.artistid)>
    <cfset QuerySetCell(NewQuerySamir,"city",testeSamir.city)>
    <cfset QuerySetCell(NewQuerySamir,"email",testeSamir.email)>
    <cfset QuerySetCell(NewQuerySamir,"fax",testeSamir.fax)>
    <cfset QuerySetCell(NewQuerySamir,"firstname",testeSamir.firstname)>
    <cfset QuerySetCell(NewQuerySamir,"lastname",testeSamir.lastname)>
    <cfset QuerySetCell(NewQuerySamir,"phone",testeSamir.phone)>
    <cfset QuerySetCell(NewQuerySamir,"postalcode",testeSamir.postalcode)>
    <cfset QuerySetCell(NewQuerySamir,"state",testeSamir.state)>
    <cfset QuerySetCell(NewQuerySamir,"thepassword",testeSamir.thepassword)>
    <cfset QuerySetCell(NewQuerySamir,"countgeral",testeSamir.recordcount)>
</cfloop>

<cfdump var="#session#">
