<cfcomponent displayname="WebFlint Benchmark" output="false"
 hint="Exposes a benchmarking interface for CFML applications to time code execution times">

<!--- 
	Usage:
	
		The benchmark is a simple component that measures the execution time of code blocks.
		
		To use the benchmark Component, you instantiate the compontent:
		
		<cfset timer = createObject("component", "com.webflint.core.benchmark.Timer").init() />
		
		You can then call the start and stop functions to capture execution times:
		
		<cfset timer.start("Example Timer") />
		
			run some code between start and stop
		
		<cfset timer.stop("Example Timer") />	
		
		the metadata for a timer includes the total execution time for all occurances and
					the number of times the timer was started and stopped
		
		<cfset result = timer.get("Example Timer") />
		<cfoutput>The Example Timer took: #result.duration#ms, and ran #result.count# times</cfoutput>
		
		You may register any number of timers by specifying a new name for the timer.start()
		function.
		
		All running timers can be returned by calling the timer.getAll() function which returns
		a structure of metadata for all the timers.  
		
		A couple functions can output the benchmarks at any given time:
		
		GRAPH OUTPUT 
		
		A png of the current benchmarks
		
		<cfoutput>#timer.list()#</cfoutput>
		
		LIST OUTPUT 
		
		a html ordered list of the current benchmarks
		
		<cfoutput>#timer.graph()#</cfoutput>
		
		
		Or you can build your own snippits.
				
		A simple snippet can be added to the bottom of a page to show this information at the 
		end of a request
		
		<cfset allTimers = timer.getAll() />
		
		<cfoutput>
		<p><strong>Benchmark results</strong>												
		<ul>
			<cfloop collection="#allTimers#" item="timer">
				<li>#timer#: (#allTimers[timer].count#) #allTimers[timer].duration#ms</li>
			</cfloop>
		</ul>
		</p>
		</cfoutput>		 
						
 --->
 
<!--- TODO:

+ Allow for descriptions to be added for bookmarks

 ---> 

<!--- INSTANCE PROPERTIES --->
<cfset variables.benchMarks = createObject("java", "java.util.LinkedHashMap").init() />

<cffunction name="init" returntype="benchmark" access="public">

  <cfargument name="global" type="string" required="true" default="$$bm"
      hint="The name of the request variable to set the benchMark singleton into" />
  
	<cfset request [ arguments.global ] = this />
	    
	<cfreturn this />

</cffunction>

<cffunction name="start" returntype="benchmark" access="public">
	
  <cfargument name="name" type="string" required="true" default=""
      hint="The name of the benchmark to start" />
	
	<cfset var local = structNew() />
	
	<cfif structKeyExists( variables.benchMarks, arguments.name ) >
		
		<cfset variables.benchMarks[ arguments.name ]["count"] = variables.benchMarks[ arguments.name ]["count"] + 1  />		
		
		<!--- if the benchMark is already running, don't reset it --->
		<cfif variables.benchMarks[ arguments.name ]["depth"] >

			<cfset variables.benchMarks[ arguments.name ]["depth"] = variables.benchMarks[ arguments.name ]["depth"] + 1 />		
		
		<cfelse>

			<cfset variables.benchMarks[ arguments.name ]["start"] = getTickCount() />
			<cfset variables.benchMarks[ arguments.name ]["depth"] = 1 />
							
		</cfif>			

	<cfelse><!--- a new benchmark --->
		
		<!--- depth maintains the number or started benchmarks of the same name to allow for nested benchmarks --->
		<cfset variables.benchMarks[ arguments.name ] = { start = getTickCount(), duration = 0, count = 1, depth=1 }  />
	
	</cfif>
	
	<cfreturn this />

</cffunction>

<cffunction name="stop" returntype="benchmark" access="public">
	
  <cfargument name="name" type="string" required="true"
      hint="The name of the benchmark to stop" />

	<cfset var local = structNew() />
		
	<cfset verifyBenchmark ( arguments.name ) />

	<cfset variables.benchMarks[ arguments.name ]["depth"] = variables.benchMarks[ arguments.name ]["depth"]  - 1 /> 

	<!--- we only stop the timer if it is not nested --->
	<cfif !variables.benchMarks[ arguments.name ]["depth"] >

		<cfset variables.benchMarks[ arguments.name ]["duration"] = variables.benchMarks[ arguments.name ]["duration"]
					+ getTickCount() - variables.benchMarks[ arguments.name ]["start"] /> 

		<cfset variables.benchMarks[ arguments.name ]["start"] = "" />

	</cfif>
						
	<cfreturn this />

</cffunction>

<cffunction name="get" returntype="struct" access="public">
	
  <cfargument name="name" type="string" required="true"
      hint="The name of the benchmark to return" />

	<cfset var local = structNew() />
		
	<cfset verifyBenchmark ( arguments.name ) />
	
	<cfreturn variables.benchMarks[ arguments.name ] />

</cffunction>

<cffunction name="getAll" returntype="struct" access="public"
	hint="Returns all bookmarks for the request">
		
	<cfreturn variables.benchMarks />

</cffunction>

<cffunction name="verifyBenchmark" returntype="benchmark" access="private" >
	
  <cfargument name="name" type="string" required="true"
      hint="The name of the benchmark to verify" />

	<cfset var local = structNew() />
		
	<cfif !structKeyExists( variables.benchMarks, arguments.name ) >
		
		<cfthrow type="webflint.core.benchmark" message="Benchmark undefined" detail="The benchmark named #arguments.name# does not exist." />
	
	</cfif>
	
	<cfreturn this />

</cffunction>

<cffunction name="graph" returntype="string"
	hint="I draw the current bookmarks as a graph">

  <cfargument name="Title" type="string" required="false" default="BenchMarks"
    hint="The title of the graph" />

  <cfargument name="chartWidth" type="numeric" required="false" default="320"
    hint="The width of the graph" />
		
	<cfset var local = structNew() />
	
	<cfset local.bm = this.getAll() />
	
	<cfsavecontent variable="local.return">
		<cfinclude template="views/graph.cfm" />
	</cfsavecontent>

	<cfreturn local.return />

</cffunction>

<cffunction name="list" returntype="string"
	hint="I draw the current bookmarks as a ordered list">
		
	<cfset var local = structNew() />
	
	<cfset local.bm = this.getAll() />
	
	<cfsavecontent variable="local.return">
		
		<cfinclude template="views/list.cfm" />
		
	</cfsavecontent>

	<cfreturn local.return />

</cffunction>

</cfcomponent>