/**
 * @name Obsolete 'apply' function usage detected
 * @description Identifies usage of the deprecated 'apply' builtin function in Python 2 code.
 *              This function is obsolete and should be replaced with modern alternatives.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Identify calls to the deprecated 'apply' function in Python 2 code
from CallNode funcCall, ControlFlowNode builtinTarget
where 
  // Restrict analysis to Python 2 environment where 'apply' was available
  major_version() = 2
  and 
  // Verify the call node references the target function
  funcCall.getFunction() = builtinTarget
  and 
  // Confirm the target function resolves to the builtin 'apply' value
  builtinTarget.pointsTo(Value::named("apply"))
// Output matching call nodes with deprecation warning
select funcCall, "Call to the obsolete builtin function 'apply'."