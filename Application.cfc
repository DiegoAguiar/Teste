<cfcomponent displayname="Application" output="true">
	<cfset this.Name="Application">
	<cfset this.sessionManagement="yes">
	<cfset this.sessionTimeout=createtimespan(0,0,1,0)>
	<cfset this.WelcomeFileList=''>
    
    <cffunction name="onError" access="public" returntype="void" output="false">
		<cfargument name="Exception" type="any" required="true"/>
        <cfargument name="EventName" type="string"/>
    </cffunction>
    
    <cffunction name="onMissingTemplate" access="public" returntype="boolean" output="false">
		<cfargument name="TargetPage" type="string" required="true"/>
        <cfset ext=Reverse(ListGetAt(Reverse(arguments.TargetPage),1,'.'))>
        <cflocation url="missingTemplate.cfm?page=#ext#">
        <cfabort>
    </cffunction>
    
</cfcomponent>