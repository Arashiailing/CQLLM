/**
 * @name 'apply' function usage detection
 * @description Identifies invocations of the deprecated 'apply' builtin function, which is considered obsolete in Python 2 and completely removed in Python 3.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python
private import semmle.python.types.Builtins

// Locate function call expressions and their corresponding function references
from CallNode functionCall, ControlFlowNode calleeFunction
where 
    // Limit the analysis scope to Python 2 codebases
    major_version() = 2 
    // Establish the connection between the call and the function being invoked
    and functionCall.getFunction() = calleeFunction 
    // Confirm that the function being called is the deprecated 'apply' builtin
    and calleeFunction.pointsTo(Value::named("apply"))
// Generate a warning for each detected usage of the obsolete 'apply' function
select functionCall, "Call to the obsolete builtin function 'apply'."