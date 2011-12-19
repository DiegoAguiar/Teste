<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Testes Webservice</title>
</head>

<!---<cfquery datasource="ORACLE_SESC_SEMINARIO" name="procs">
    select a.object_name
    , p.procedure_name 
    from sys.all_objects a
    , sys.all_procedures p 
    where a.object_name = p.object_name 
    and a.object_type = 'PACKAGE'
    and a.object_name = 'CGS_WEB_SERVICE'
    and p.procedure_name is not null
</cfquery>

<cfquery name="argumentos" datasource="ORACLE_SESC_SEMINARIO">
    select *
    from sys.all_arguments
    where package_name = 'CGS_WEB_SERVICE'
    and object_name = 'LISTA_ESTADO_CIVIL'
</cfquery>--->

<!---<cfquery name="code" datasource="ORACLE_SESC_SEMINARIO" maxrows="1000">
    select text
    from sys.all_source
    where type = 'PACKAGE BODY'
    and name = 'CGS_WEB_SERVICE'
</cfquery>--->

<!---<cfquery name="code" datasource="ORACLE_SESC_SEMINARIO" maxrows="1000">
	select CGSS_TIPO_ATIVIDADE from CGS_ATIVIDADE group by CGSS_TIPO_ATIVIDADE
</cfquery>
<cfdump var="#code#"><cfabort>--->


<cfset teste='<?xml version="1.0" encoding="ISO-8859-1"?><PARAMETROS_ENTRADA><CLIENTE></CLIENTE></PARAMETROS_ENTRADA>'>
  
<cfinvoke webservice="http://127.0.0.1:8500/Testes/seminario.cfc?wsdl" method="fncCatFuncional" returnvariable="XML_GRADE">
	<!---<cfinvokeargument name="XML_ENTRADA" value="#teste#">
    <cfinvokeargument name="CGI_CODIGO" value="0">
    <cfinvokeargument name="CGSS_TIPO_ATIVIDADE" value="1">
</cfinvoke>--->
     
     
     <!---<cfset ConsultaSeminario=CreateObject('component','seminario')>
     <cfset XML_GRADE=ConsultaSeminario.fncConsultaSeminario(DT_STR_INI='01011989',DT_STR_FIM='19122011',UOR_CODIGO=0)>--->

<cfdump var="#XML_GRADE#">
<body>
</body>
</html>