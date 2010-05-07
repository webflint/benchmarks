The benchmark is a simple component that measures the execution time of code blocks.
	
	To use the benchmark Component, you instantiate the compontent:
	
	<cfset timer = createObject("component", "com.webflint.benchmarks.Benchmark").init() />
	
	You can then call the start and stop functions to capture execution times:
	
	<cfset timer.start("Example Timer") />
	
		run some code between start and stop
	
	<cfset timer.stop("Example Timer") />	
	
	the metadata for a timer includes the total execution time for all occurances and
				the number of times the timer was started and stopped.
		
	<cfset result = timer.get("Example Timer") />
	<cfoutput>The Example Timer took: #result.duration#ms, and ran #result.count# times</cfoutput>
	
	You may register any number of timers by specifying a new name for the timer.start( name )
	function.
				
	timers can also be nested.
	
	All running timers can be returned by calling the timer.getAll() function which returns
	a structure of metadata for all the timers.  
	
	A couple functions can output the current benchmarks at any given time and give you
	a visual view of the timers:

	
	LIST OUTPUT 
	
	a html ordered list of the current benchmarks
	
	<cfoutput>#timer.list()#</cfoutput>
		
	GRAPH OUTPUT 
	
	A png of the current benchmarks, yay CFCHART
	
	<cfoutput>#timer.graph()#</cfoutput>

	
	Or you can build your own output templates.
			
	A simple snippet can be added to the bottom of a page to show this information at the 
	end of a request, and you can display the results as you wish.
	
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