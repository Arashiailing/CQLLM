/**
 * @name 'apply' function usage detection
 * @description Identifies usage of the obsolete 'apply' builtin function which is deprecated in Python 2 and removed in Python 3.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python  // Import Python library for code analysis
private import semmle.python.types.Builtins  // Private import for Python built-in types functionality

// Define source nodes: function call and control flow nodes
from CallNode functionCall, ControlFlowNode calledFunction
// Set conditions: Python version 2, function call points to the 'apply' builtin function
where 
    major_version() = 2 and 
    functionCall.getFunction() = calledFunction and 
    calledFunction.pointsTo(Value::named("apply"))
// Select the problematic function call with appropriate warning message
select functionCall, "Call to the obsolete builtin function 'apply'."