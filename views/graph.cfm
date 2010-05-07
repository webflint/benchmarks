<!--- displays the benchmarks in a graph --->
<cfchart format="png" showlegend="true" attributeCollection="#arguments#">

	<cfchartseries type="bar" seriescolor="blue">

		<cfloop collection="#local.bm#" item="local.idx">			

			<cfchartdata item="#local.idx#" value="#local.bm [ local.idx ].duration#" />
			
		</cfloop>
		
	</cfchartseries>

</cfchart>