<cfcomponent displayname="Mapping" 
		output="false" 
		extends="Base" 
		hint="Manage mappings - OpenBD Admin API">

	<cffunction name="getMappings" access="public" output="false" returntype="array" 
			hint="Returns array of mappings which equate logical paths to directory paths">
		<cfargument name="mapName" required="false" type="string" hint="The mapping to retrieve" />
		
		<cfset var localConfig = getConfig() />
		<cfset var mapIndex = "" />
		<cfset var returnArray = ArrayNew(1) />

		<!--- Make sure there are Mappings --->
		<cfif (NOT StructKeyExists(localConfig, "cfmappings")) OR (NOT StructKeyExists(localConfig.cfmappings, "mapping"))>
			<cfthrow message="No Mappings Defined" type="bluedragon.adminapi.mapping">		
		</cfif>

		<!--- Return entire Mapping array, unless a map name is specified --->
		<cfif NOT IsDefined("arguments.mapName")>
			<cfreturn localConfig.cfmappings.mapping />
		<cfelse>
			<cfloop index="mapIndex" from="1" to="#ArrayLen(localConfig.cfmappings.mapping)#">
				<cfif localConfig.cfmappings.mapping[mapIndex].name EQ arguments.mapName>
					<cfset returnArray[1] = Duplicate(localConfig.cfmappings.mapping[mapIndex]) />
					<cfreturn returnArray />
				</cfif>
			</cfloop>
			<cfthrow message="#arguments.mapName# is not defined as a mapping" type="bluedragon.adminapi.mapping">
		</cfif>
	</cffunction>

	<cffunction name="saveMapping" access="public" output="false" returntype="void" 
				hint="Creates a mapping, equating a logical path to a directory path">
		<cfargument name="name" type="string" required="true" hint="Logical path name" />
		<cfargument name="directory" type="string" required="true" hint="Directory path name" />
		<cfargument name="action" type="string" required="false" default="create" hint="Mapping action (create or update)" />
		<cfargument name="existingMappingName" type="string" required="false" default="" 
				hint="Existing mapping name--used in the event of a name update" />
		
		<cfset var localConfig = getConfig() />
		<cfset var mapping = StructNew() />
		<cfset var tempPath = "" />
		
		<!--- Make sure configuration structure exists, otherwise build it --->
		<cfif (NOT StructKeyExists(localConfig, "cfmappings")) OR (NOT StructKeyExists(localConfig.cfmappings, "mapping"))>
			<cfset localConfig.cfmappings.mapping = ArrayNew(1) />
		</cfif>
		
		<!--- make sure we can hit the physical directory --->
		<cftry>
			<cfif left(arguments.directory, 1) is "$">
				<cfset tempPath = right(arguments.directory, len(arguments.directory) - 1) />
			<cfelse>
				<cfset tempPath = arguments.directory />
			</cfif>
			
			<cfif not directoryExists(tempPath)>
				<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
						type="bluedragon.adminapi.mapping" />
			</cfif>
			<cfcatch type="any">
				<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
						type="bluedragon.adminapi.mapping" />
			</cfcatch>
		</cftry>
		
		<!--- if this is an edit, delete the existing mapping --->
		<cfif arguments.action is "update">
			<cfset deleteMapping(arguments.existingMappingName) />
			<cfset localConfig = getConfig() />
			
			<!--- if that was the only mapping, need to recreate the mapping structure --->
			<cfif (NOT StructKeyExists(localConfig, "cfmappings")) OR (NOT StructKeyExists(localConfig.cfmappings, "mapping"))>
				<cfset localConfig.cfmappings.mapping = ArrayNew(1) />
			</cfif>
		</cfif>
		
		<!--- Build Mapping Struct --->
		<cfset mapping.name = arguments.name />
		<cfset mapping.directory = arguments.directory />

		<!--- Prepend it to the Mapping array --->
		<cfset ArrayPrepend(localConfig.cfmappings.mapping, Duplicate(mapping)) />
	
		<cfset setConfig(localConfig) />
	</cffunction>
	
	<cffunction name="verifyMapping" access="public" output="false" returntype="void" 
			hint="Verifies the mapping by running cfdirectory on both the physical and logical paths">
		<cfargument name="mappingName" type="string" required="true" />
		
		<cfset var mapping = getMappings(arguments.mappingName) />
		<cfset var tempPath = "" />
		
		<cfset mapping = mapping[1] />
		
		<!--- check the physical directory --->
		<cftry>
			<cfif left(mapping.directory, 1) is "$">
				<cfset tempPath = right(mapping.directory, len(mapping.directory) - 1) />
			<cfelse>
				<cfset tempPath = mapping.directory />
			</cfif>
			
			<cfif not directoryExists(tempPath)>
				<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
						type="bluedragon.adminapi.mapping" />
			</cfif>
			<cfcatch type="any">
				<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
						type="bluedragon.adminapi.mapping" />
			</cfcatch>
		</cftry>
		
		<!--- check the logical path --->
		<cftry>
			<cfif not directoryExists(expandPath(mapping.name))>
				<cfthrow message="The logical path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
						type="bluedragon.adminapi.mapping" />
			</cfif>
			<cfcatch type="any">
				<cfthrow message="The logical path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
						type="bluedragon.adminapi.mapping" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deleteMapping" access="public" output="false" returntype="void" hint="Delete the specified mapping">
		<cfargument name="mapName" required="true" type="string" hint="Specifies a logical path name" />
		<cfset var localConfig = getConfig() />
		<cfset var mapIndex = "" />

		<!--- Make sure there are Mappings --->
		<cfif (NOT StructKeyExists(localConfig, "cfmappings")) OR (NOT StructKeyExists(localConfig.cfmappings, "mapping"))>
			<cfthrow message="No Mappings Defined" type="bluedragon.adminapi.mapping">		
		</cfif>

		<cfloop index="mapIndex" from="1" to="#ArrayLen(localConfig.cfmappings.mapping)#">
			<cfif localConfig.cfmappings.mapping[mapIndex].name EQ arguments.mapName>
				<cfset ArrayDeleteAt(localConfig.cfmappings.mapping, mapIndex) />
				<cfset setConfig(localConfig) />
				<cfreturn />
			</cfif>
		</cfloop>
		<cfthrow message="#arguments.mapName# is not defined as a mapping" type="bluedragon.adminapi.mapping">
	</cffunction>

</cfcomponent>