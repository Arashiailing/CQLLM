/**
 * @name Obsolete 'apply' function usage detected
 * @description Identifies deprecated 'apply' builtin calls in Python 2 code.
 *              This function is obsolete and should be replaced with direct
 *              function calls or the * operator for argument unpacking.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Identify Python 2 code calling the deprecated 'apply' builtin
from CallNode applyCall, ControlFlowNode targetFunction
where 
  // Restrict to Python 2 where 'apply' was available
  major_version() = 2
  and 
  // Link call node to its target function
  applyCall.getFunction() = targetFunction
  and 
  // Confirm target is the builtin 'apply' function
  targetFunction.pointsTo(Value::named("apply"))
// Report each obsolete call with warning message
select applyCall, "Call to the obsolete builtin function 'apply'."