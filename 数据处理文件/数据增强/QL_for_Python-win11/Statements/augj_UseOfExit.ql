/**
 * @name Use of exit() or quit()
 * @description Detects calls to exit() or quit() which may fail when Python is run with -S option
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // Core Python analysis module for AST traversal

from CallNode invocation, string functionName  // Identify function call nodes and their names
where 
  // Match calls pointing to site module's Quitter objects (exit/quit)
  invocation.getFunction().pointsTo(Value::siteQuitter(functionName))
select 
  invocation,  // Report the problematic call location
  "The '" + functionName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."  // Contextual warning message