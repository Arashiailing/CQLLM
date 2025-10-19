/**
 * @name Nested loops with same variable
 * @description Identifies nested for-loops that utilize identical iteration variables,
 *              which may cause confusion and introduce potential defects.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Helper predicate that checks if a loop iterates over a specific variable
predicate iterationTarget(For loopNode, Variable iteratedVar) { 
    loopNode.getTarget().defines(iteratedVar) 
}

// Main analysis: Find nested loops sharing iteration variables
from For nestedLoop, For enclosingLoop, Variable commonIterVar
where 
    // Confirm direct nesting relationship (inner loop inside outer loop's body)
    enclosingLoop.getBody().contains(nestedLoop) and
    // Both loops must iterate over the same variable
    iterationTarget(nestedLoop, commonIterVar) and
    iterationTarget(enclosingLoop, commonIterVar) and
    // Ensure the variable is actually referenced in the outer loop's scope
    exists(Name varReference | 
        varReference.uses(commonIterVar) and 
        enclosingLoop.contains(varReference) and 
        not nestedLoop.contains(varReference)
    )
select nestedLoop, 
    "Nested for statement reuses iteration variable '" + commonIterVar.getId() + 
    "' from enclosing $@.", 
    enclosingLoop, 
    "for statement"