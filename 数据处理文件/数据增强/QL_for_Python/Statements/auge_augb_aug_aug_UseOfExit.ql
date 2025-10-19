/**
 * @name Use of exit() or quit()
 * @description Detects calls to exit() or quit() functions which are provided 
 *              by the site module. These functions may be unavailable when 
 *              Python runs with the -S flag that disables site module loading.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode siteExitCall, string siteExitName
where 
  // Verify the call targets a site.Quitter object
  siteExitCall.getFunction().pointsTo(Value::siteQuitter(siteExitName))
select 
  siteExitCall,
  "Function '" + siteExitName + 
  "' is a site.Quitter object that may not exist when the 'site' module is disabled or modified."