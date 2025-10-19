/**
 * @name Nested loops with same variable
 * @description Identifies nested for loops that reuse identical iteration variables,
 *              potentially causing unexpected behavior and reducing code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks whether a for loop uses the specified variable as its iteration target
predicate forLoopUsesVariable(For loopStmt, Variable targetVar) { 
  loopStmt.getTarget().defines(targetVar) 
}

// Identifies nested for loops that share an iteration variable and potentially cause issues
predicate problematicNestedLoops(For innerLoop, For outerLoop, Variable commonVar) {
  // Both loops must utilize the same variable for iteration
  forLoopUsesVariable(innerLoop, commonVar) and
  forLoopUsesVariable(outerLoop, commonVar) and
  // Inner loop must be directly nested within the outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // The shared variable must be referenced in the outer loop outside the inner loop's scope
  exists(Name varReference | 
    varReference.uses(commonVar) and 
    outerLoop.contains(varReference) and 
    not innerLoop.contains(varReference)
  )
}

// Main query to find all instances of problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVar
where problematicNestedLoops(innerLoop, outerLoop, commonVar)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"