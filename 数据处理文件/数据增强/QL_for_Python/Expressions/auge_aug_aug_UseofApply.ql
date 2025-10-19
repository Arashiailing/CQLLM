/**
 * @name Obsolete 'apply' function usage detected
 * @description This query identifies uses of the deprecated 'apply' builtin function in Python 2 code.
 *              The 'apply' function is considered obsolete and should be replaced with modern
 *              alternatives like direct function calls or the * operator for argument unpacking.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Find all function call nodes that reference the deprecated 'apply' builtin
from CallNode invocationNode, ControlFlowNode calledFunction
where 
  // Restrict analysis to Python 2 code where 'apply' was available as a builtin
  major_version() = 2
  and 
  // Establish relationship between the call node and its target function
  invocationNode.getFunction() = calledFunction
  and 
  // Verify the target function is indeed the builtin 'apply'
  calledFunction.pointsTo(Value::named("apply"))
// Report each identified call with an appropriate warning message
select invocationNode, "Call to the obsolete builtin function 'apply'."