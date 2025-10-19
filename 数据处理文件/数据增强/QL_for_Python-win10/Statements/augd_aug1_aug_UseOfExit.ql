/**
 * @name Potentially unsafe exit() or quit() usage
 * @description Detects calls to exit() or quit() functions that may fail when Python runs with the '-S' flag, which prevents the site module from being imported. These functions rely on site module functionality that might be unavailable.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode unsafeCall, string funcName
where 
  // Check if the call targets site.QuitTer objects (exit/quit)
  unsafeCall.getFunction().pointsTo(Value::siteQuitter(funcName))
select 
  unsafeCall,
  "The '" + funcName + 
  "' function depends on the site module and may not function when 'site' is disabled or altered."