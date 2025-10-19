/**
 * @name Use of exit() or quit()
 * @description Identifies calls to exit() or quit() functions that may fail 
 *              when Python runs with -S flag (disables 'site' module)
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode problematicCall, string functionName
where 
  // Verify the call targets site module's Quitter object
  problematicCall.getFunction().pointsTo(Value::siteQuitter(functionName))
select 
  problematicCall,
  "The '" + functionName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."