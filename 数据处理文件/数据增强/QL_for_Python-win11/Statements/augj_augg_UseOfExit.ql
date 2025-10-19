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

from CallNode callNode, string functionName  // Obtain function call nodes and their corresponding names
where 
  // Identify calls to functions that point to siteQuitter objects
  callNode.getFunction().pointsTo(Value::siteQuitter(functionName))
select callNode,  // Output the matching function call nodes
  "Potential issue: '" + functionName +
    "' is a site.Quitter object that may not exist if the 'site' module is not loaded or has been modified."  // Warning about site.Quitter object availability