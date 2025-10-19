/**
 * @name Use of exit() or quit() functions
 * @description Identifies calls to exit() or quit() that might not work properly 
 *              when Python is executed with the -S flag, which disables the 'site' module.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // Import the Python module to enable analysis of Python code structures

from CallNode riskyCall, string exitFunctionName  // Get call node and exit function name
where 
  // Verify if the call targets the site module's Quitter object
  riskyCall.getFunction().pointsTo(Value::siteQuitter(exitFunctionName))
select 
  riskyCall,  // Select matching method calls
  "The '" + exitFunctionName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."