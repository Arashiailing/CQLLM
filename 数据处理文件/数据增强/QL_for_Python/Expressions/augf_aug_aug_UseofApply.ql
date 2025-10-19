/**
 * @name Deprecated 'apply' function usage detection
 * @description Detects calls to the outdated 'apply' builtin function in Python 2 codebases.
 *              This function has been deprecated and should be replaced with contemporary approaches.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Identify function call expressions and their corresponding function references
from CallNode functionCall, ControlFlowNode calledFunction
where 
  // Limit the analysis scope to Python 2 environments where 'apply' was a builtin
  major_version() = 2
  and 
  // Establish the relationship between the call node and its target function
  functionCall.getFunction() = calledFunction
  and 
  // Verify that the called function resolves to the builtin 'apply' identifier
  calledFunction.pointsTo(Value::named("apply"))
// Report identified call nodes with an appropriate deprecation warning
select functionCall, "Call to the obsolete builtin function 'apply'."