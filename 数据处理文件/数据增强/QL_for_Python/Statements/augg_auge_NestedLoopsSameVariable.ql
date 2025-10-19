/**
 * @name Nested loops with identical loop variable
 * @description Identifies nested for-loops that reuse the same iteration variable,
 *              potentially causing unintended behavior and reducing code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks if a for-loop uses the specified variable as its iterator
predicate hasIterationVariable(For loop, Variable iterVar) { 
    loop.getTarget().defines(iterVar) 
}

// Detects nested loops sharing the same iterator variable where the variable
// is referenced in the outer loop's scope (excluding the inner loop)
predicate hasConflictingNestedLoop(For innerLoop, For outerLoop, Variable sharedVar) {
    // Ensure inner loop is directly nested in outer loop's body (not else clause)
    outerLoop.getBody().contains(innerLoop) and
    
    // Verify both loops use the same iteration variable
    hasIterationVariable(innerLoop, sharedVar) and
    hasIterationVariable(outerLoop, sharedVar) and
    
    // Confirm the variable is used in the outer loop's scope
    exists(Name usage | 
        usage.uses(sharedVar) and 
        outerLoop.contains(usage) and 
        not innerLoop.contains(usage)
    )
}

// Locate all instances of problematic nested loops with shared iteration variables
from For nestedLoop, For enclosingLoop, Variable loopVar
where hasConflictingNestedLoop(nestedLoop, enclosingLoop, loopVar)
select nestedLoop, 
    "Nested for-loop reuses iteration variable '" + loopVar.getId() + 
    "' from enclosing $@.", 
    enclosingLoop, 
    "for-loop"