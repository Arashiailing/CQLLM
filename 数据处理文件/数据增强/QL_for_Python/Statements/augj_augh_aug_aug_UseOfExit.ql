/**
 * @name Use of exit() or quit()
 * @description Identifies calls to exit() or quit() functions that depend on the 'site' module.
 *              These functions may be unavailable when Python runs with -S flag (disables site module).
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode exitInvocation, string quitterName
where 
  // Verify the call targets site module's Quitter object (exit/quit)
  exitInvocation.getFunction()
    .pointsTo(Value::siteQuitter(quitterName))
select 
  exitInvocation,
  "The '" + quitterName + 
  "' function relies on site.Quitter which may not exist when 'site' module is disabled or modified."