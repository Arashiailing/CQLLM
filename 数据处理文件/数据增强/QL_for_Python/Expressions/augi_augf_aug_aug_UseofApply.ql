/**
 * @name Deprecated 'apply' function usage detection
 * @description Identifies usage of the deprecated 'apply' builtin function in Python 2 code.
 *              This function is obsolete and should be replaced with modern Python constructs.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Extract function invocations and their corresponding target function references
from CallNode functionInvocation, ControlFlowNode targetFunction
where 
  // Restrict analysis to Python 2 environments where 'apply' was available as a builtin
  major_version() = 2
  and 
  // Establish the connection between the invocation and its target function
  functionInvocation.getFunction() = targetFunction
  and 
  // Confirm that the target function resolves to the builtin 'apply' identifier
  targetFunction.pointsTo(Value::named("apply"))
// Output the identified function invocations with a deprecation warning message
select functionInvocation, "Call to the obsolete builtin function 'apply'."