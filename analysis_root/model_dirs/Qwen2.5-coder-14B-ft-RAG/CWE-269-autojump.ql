/**
 * @name CWE-269: Improper Privilege Management
 * @description The product does not properly assign, modify, track, or check privileges for an actor, creating an unintended sphere of control for that actor.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/autojump
 * @tags correctness
 */

import python
import semmle.python.ApiGraphs

// Finds instances where autojump's Jump class is imported and used to execute commands
from Import imp, Expr cmdExec
where
  // Check if the 'autojump.Jump' module is being imported
  imp.imports("autojump.Jump", any()) and
  // Find calls to methods of the imported Jump class
  cmdExec.(Call).getFunc().(Attribute).getObject() = imp.getAnImportedModule()
select cmdExec, "Execution performed by autojump.Jump."