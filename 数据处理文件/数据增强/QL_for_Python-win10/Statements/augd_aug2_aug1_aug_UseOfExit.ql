/**
 * @name Potentially unsafe exit() or quit() usage
 * @description Identifies calls to exit() or quit() functions that are defined in the site module.
 *              These calls may fail when Python runs with the '-S' flag, which prevents loading
 *              the site module where these functions are defined. Consider using sys.exit() instead.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode problematicExitCall, string exitFuncName
where 
  // Identify function calls that reference site.Quitter objects (exit/quit)
  problematicExitCall.getFunction().pointsTo(Value::siteQuitter(exitFuncName))
select 
  problematicExitCall,
  "Usage of '" + exitFuncName + 
  "' depends on site module availability and may fail when Python runs with '-S' flag."