/**
 * @name Use of exit() or quit()
 * @description Detects calls to exit() or quit() which may fail under '-S' interpreter option.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode funcCall, string funcName
where 
  // Check if the called function points to site.Quitter objects (exit/quit)
  funcCall.getFunction().pointsTo(Value::siteQuitter(funcName))
select 
  funcCall,
  "The '" + funcName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."