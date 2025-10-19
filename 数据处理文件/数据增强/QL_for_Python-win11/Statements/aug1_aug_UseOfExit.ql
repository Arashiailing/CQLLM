/**
 * @name Potentially unsafe exit() or quit() usage
 * @description Identifies calls to exit() or quit() functions that might not work when Python is started with the '-S' option, which disables the import of the site module.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode exitOrQuitCall, string exitOrQuitName
where 
  // Verify if the function call targets a site.Quitter object (exit/quit)
  exitOrQuitCall.getFunction().pointsTo(Value::siteQuitter(exitOrQuitName))
select 
  exitOrQuitCall,
  "The '" + exitOrQuitName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."