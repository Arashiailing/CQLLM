/**
 * @name Nested loops reusing identical iteration variable
 * @description Detects nested for-loops utilizing the same iteration variable,
 *              which may lead to unintended behavior and reduced code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines whether a loop employs the specified variable as its iteration target
predicate employsIterationTarget(For loopStmt, Variable loopVar) { 
  loopStmt.getTarget().defines(loopVar) 
}

// Identifies nested loops sharing identical iteration variables where the variable
// is referenced outside the inner loop's scope within the outer loop context
predicate sharesVariableInNestedLoops(For innerFor, For outerFor, Variable sharedVar) {
  // Validate inner loop is directly nested in outer loop's body (excluding else blocks)
  outerFor.getBody().contains(innerFor) and
  // Verify both loops utilize the same iteration variable
  employsIterationTarget(innerFor, sharedVar) and
  employsIterationTarget(outerFor, sharedVar) and
  // Confirm variable usage exists in outer loop beyond inner loop's scope
  exists(Name varReference | 
    varReference.uses(sharedVar) and 
    outerFor.contains(varReference) and 
    not innerFor.contains(varReference)
  )
}

// Query: Locate problematic nested loops with shared iteration variables
from For innerFor, For outerFor, Variable sharedVar
where sharesVariableInNestedLoops(innerFor, outerFor, sharedVar)
select innerFor, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  outerFor, 
  "outer for loop"