<!--- updateCell.cfm --->
<cfsetting showdebugoutput="No">
<cfsetting enablecfoutputonly="Yes">

<cfparam name="form.tableName" default="">
<cfparam name="form.rowId" default="">
<cfparam name="form.column" default="">
<cfparam name="form.pkName" default="idcode">
<cfparam name="form.value" default="">

<cfif isArray(form.value)>
	<cfset form.value = form.value[1]>
</cfif>

<cfif form.tableName EQ "" OR form.rowId EQ "" OR form.column EQ "" OR form.pkName EQ "">
	<cfoutput>{"status":"error","message":"Missing parameters"}</cfoutput><cfexit>
	
</cfif>

<cfquery name="allTables" datasource="#cookie.cooksql_mainsync#_active">
	SELECT tablename FROM pg_tables WHERE schemaname='public'
</cfquery>
<cfset allowedTables = []>
<cfloop query="allTables">
	<cfset arrayAppend(allowedTables, allTables.tablename)>
</cfloop>
<cfif NOT listFindNoCase(arrayToList(allowedTables), form.tableName)>
	<cfoutput>{"status":"error","message":"Invalid table name"}</cfoutput><cfexit>
	
</cfif>

<cfquery name="colQuery" datasource="#cookie.cooksql_mainsync#_active">
	SELECT column_name FROM information_schema.columns
	WHERE table_name = <cfqueryparam value="#form.tableName#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfset allowedColumns = []>
<cfloop query="colQuery">
	<cfset arrayAppend(allowedColumns, colQuery.column_name)>
</cfloop>
<cfif NOT listFindNoCase(arrayToList(allowedColumns), form.column)>
	<cfoutput>{"status":"error","message":"Invalid column name"}</cfoutput><cfexit>
	
</cfif>



<cfquery name="pkTypeQuery" datasource="#cookie.cooksql_mainsync#_active">
	SELECT data_type
	FROM information_schema.columns
	WHERE table_name = <cfqueryparam value="#form.tableName#" cfsqltype="cf_sql_varchar">
	AND column_name = <cfqueryparam value="#form.pkName#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfset pkType = pkTypeQuery.data_type>
<cfif pkType EQ "integer" OR pkType EQ "bigint" OR pkType EQ "smallint">
	<cfset pkSqlType = "cf_sql_integer">
	<cfset pkValue = val(form.rowId)>
<cfelse>
	<cfset pkSqlType = "cf_sql_varchar">
	<cfset pkValue = form.rowId>
</cfif>

<cftry>
	<cfquery datasource="#cookie.cooksql_mainsync#_active" name="updateQuery">
		UPDATE #form.tableName#
		SET "#form.column#" = <cfqueryparam value="#form.value#" cfsqltype="cf_sql_varchar">
		WHERE "#form.pkName#" = <cfqueryparam value="#pkValue#" cfsqltype="#pkSqlType#">
	</cfquery>
	<cfoutput>#serializeJSON({"status":"success","message":"Update successful"})#</cfoutput>
	<cfcatch>
		<cfoutput>#serializeJSON({"status":"error","message":cfcatch.message})#</cfoutput>
	</cfcatch>
</cftry>
