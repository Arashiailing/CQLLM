/**
 * @name 'apply' function usage detection
 * @description Identifies calls to the deprecated 'apply' builtin function, which is obsolete in Python 2 and removed in Python 3.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python  // Core Python analysis library
private import semmle.python.types.Builtins  // Specialized built-in type handling

// Identify problematic function calls and their target references
from CallNode applyCall, ControlFlowNode applyTarget
where 
    // Restrict analysis to Python 2 environments
    major_version() = 2 and 
    // Establish call-target relationship
    applyCall.getFunction() = applyTarget and 
    // Verify target points to the deprecated 'apply' builtin
    applyTarget.pointsTo(Value::named("apply"))
// Report deprecated usage with contextual warning
select applyCall, "Call to the obsolete builtin function 'apply'."