/**
 * @name Deprecated 'apply' function usage
 * @description Detects calls to the deprecated 'apply' builtin function in Python 2.
 *              This function is obsolete and should be replaced with modern constructs.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Select function call nodes and their corresponding target functions
from CallNode funcCall, ControlFlowNode calledFunc
where 
  // Restrict analysis to Python 2 code where 'apply' was available
  major_version() = 2
  and 
  // Verify the call node references the target function
  funcCall.getFunction() = calledFunc
  and 
  // Confirm the target function points to the builtin 'apply' value
  calledFunc.pointsTo(Value::named("apply"))
// Output matching call nodes with a descriptive warning message
select funcCall, "Call to the obsolete builtin function 'apply'."