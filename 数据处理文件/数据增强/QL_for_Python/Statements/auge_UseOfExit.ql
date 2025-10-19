/**
 * @name Use of exit() or quit()
 * @description Using exit() or quit() may cause failures when the Python interpreter runs with -S option
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode functionCall, string quitterName
where 
  // Check if the function call references a site.Quitter object
  functionCall.getFunction().pointsTo(Value::siteQuitter(quitterName))
select 
  functionCall,
  "The '" + quitterName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or modified."