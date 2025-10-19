/**
 * @name Potentially unsafe exit() or quit() usage
 * @description Detects calls to exit() or quit() functions that may fail when Python runs with '-S' flag,
 *              which prevents loading the site module where these functions are defined.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode siteQuitterCall, string quitterFunctionName
where 
  // Identify function calls targeting site.Quitter objects (exit/quit)
  siteQuitterCall.getFunction().pointsTo(Value::siteQuitter(quitterFunctionName))
select 
  siteQuitterCall,
  "Usage of '" + quitterFunctionName + 
  "' relies on site module availability and may fail when site isn't loaded."