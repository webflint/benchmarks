<ol>
	<cfloop collection="#local.bm#" item="local.idx">			

		<cfoutput><li><strong>#local.bm [ local.idx ].duration#ms [#get( local.idx ).count#]</strong> #local.idx#</li></cfoutput>
		
	</cfloop>
</ol>