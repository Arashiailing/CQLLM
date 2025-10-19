/**
 * @name Nested loops reusing iteration variable
 * @description Detects nested loops where both outer and inner loops utilize identical variables
 *              as their iteration target. This practice may cause the inner loop to overwrite
 *              the outer loop's variable, resulting in unexpected behavior and diminished code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Check if a loop variable is used as the iteration target in a for loop
predicate loopUsesVariableAsTarget(For loopStatement, Variable loopVariable) { 
  loopStatement.getTarget().defines(loopVariable) 
}

// Find nested loops that share the same iteration variable,
// and where the variable is referenced outside the inner loop's scope
predicate hasConflictingNestedLoop(For innerLoop, For outerLoop, Variable sharedVariable) {
  // The inner loop must be directly contained within the outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Both loops must use the same variable as their iteration target
  loopUsesVariableAsTarget(innerLoop, sharedVariable) and
  loopUsesVariableAsTarget(outerLoop, sharedVariable) and
  // The shared variable must be referenced in the outer loop but outside the inner loop
  exists(Name variableReference | 
    variableReference.uses(sharedVariable) and 
    outerLoop.contains(variableReference) and 
    not innerLoop.contains(variableReference)
  )
}

// Query to identify and report nested loops with problematic shared iteration variables
from For innerForLoop, For outerForLoop, Variable iterationVariable
where hasConflictingNestedLoop(innerForLoop, outerForLoop, iterationVariable)
select innerForLoop, 
  "Nested for loop reuses iteration variable '" + iterationVariable.getId() + 
  "' from enclosing $@.", 
  outerForLoop, 
  "outer for loop"