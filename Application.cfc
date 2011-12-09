<cfcomponent displayname="Application" output="false">
	<cfset this.Name="Application">
	<cfset this.sessionManagement="yes">
	<cfset this.sessionTimeout=createtimespan(0,0,1,0)>
	<cfset this.WelcomeFileList='AdministratorAPI.cfm,index.cfm'>
    
    <cffunction name="onApplicationStart" access="public" returntype="boolean">
    	<cfset JavaCast('integer',variables.teste)>
    </cffunction>
    
    <cffunction name="onError" access="public" returntype="void" output="false">
		<cfargument name="Exception" type="any" required="true"/>
        <cfargument name="EventName" type="string"/>
		<cfdump var="#arguments.Exception#" label="Exception">
        <cfdump var="#arguments.EventName#" label="EventName"><cfabort>
    </cffunction>
    
    
</cfcomponent>