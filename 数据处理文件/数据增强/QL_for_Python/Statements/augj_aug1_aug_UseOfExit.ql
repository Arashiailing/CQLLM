/**
 * @name Potentially unsafe exit() or quit() usage
 * @description Detects calls to exit() or quit() functions that may fail when Python runs with the '-S' flag,
 *              which prevents automatic loading of the site module where these functions are defined.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode siteExitOrQuitCall, string siteQuitterName
where 
  // Identify calls pointing to site.Quitter objects (exit/quit)
  siteExitOrQuitCall.getFunction().pointsTo(Value::siteQuitter(siteQuitterName))
select 
  siteExitOrQuitCall,
  "The '" + siteQuitterName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."