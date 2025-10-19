/**
 * @name Potentially unsafe exit() or quit() usage
 * @description Detects calls to exit() or quit() functions defined in the site module.
 *              These calls may fail when Python runs with the '-S' flag, which prevents
 *              loading the site module where these functions are defined. Consider using
 *              sys.exit() instead for robustness.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode unsafeExitCall, string exitOrQuitFuncName
where 
  // Identify function calls referencing site.Quitter objects (exit/quit)
  unsafeExitCall.getFunction().pointsTo(Value::siteQuitter(exitOrQuitFuncName))
select 
  unsafeExitCall,
  "Usage of '" + exitOrQuitFuncName + 
  "' depends on site module availability and may fail when Python runs with '-S' flag."