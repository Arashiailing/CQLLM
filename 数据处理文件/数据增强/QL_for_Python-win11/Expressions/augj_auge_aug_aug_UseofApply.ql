/**
 * @name Obsolete 'apply' function usage detected
 * @description Identifies deprecated 'apply' builtin function usage in Python 2 code.
 *              This function is obsolete and should be replaced with direct function calls
 *              or argument unpacking using the * operator.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Identify call nodes targeting the deprecated 'apply' builtin
from CallNode applyCall, ControlFlowNode targetFunction
where 
  // Restrict analysis to Python 2 where 'apply' was available as builtin
  major_version() = 2
  and 
  // Link call node to its target function
  applyCall.getFunction() = targetFunction
  and 
  // Confirm target function is the builtin 'apply'
  targetFunction.pointsTo(Value::named("apply"))
// Report findings with consistent warning message
select applyCall, "Call to the obsolete builtin function 'apply'."