/**
 * @name Use of exit() or quit()
 * @description Detects usage of exit() or quit() functions which might fail when the Python interpreter is run with the -S option.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // Import Python library for analyzing Python code

from CallNode funcInvocation, string funcName  // Obtain function call nodes and their corresponding names
where 
  // Identify calls to functions that point to siteQuitter objects
  funcInvocation.getFunction().pointsTo(Value::siteQuitter(funcName))
select funcInvocation,  // Output the matching function call nodes
  "Potential issue: '" + funcName +
    "' is a site.Quitter object that may not exist if the 'site' module is not loaded or has been modified."  // Warning about site.Quitter object availability