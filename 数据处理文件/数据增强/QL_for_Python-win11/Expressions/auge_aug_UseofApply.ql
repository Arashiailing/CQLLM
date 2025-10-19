/**
 * @name 'apply' function usage detection
 * @description Detects calls to the deprecated 'apply' builtin function, which is obsolete in Python 2 and unavailable in Python 3.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Identify function call nodes and their corresponding function references
from CallNode invocation, ControlFlowNode targetFunction
where 
    // Restrict analysis to Python 2 codebase
    major_version() = 2 
    // Establish relationship between call and its target function
    and invocation.getFunction() = targetFunction 
    // Verify the target is the deprecated 'apply' builtin
    and targetFunction.pointsTo(Value::named("apply"))
// Report problematic calls with deprecation warning
select invocation, "Call to the obsolete builtin function 'apply'."