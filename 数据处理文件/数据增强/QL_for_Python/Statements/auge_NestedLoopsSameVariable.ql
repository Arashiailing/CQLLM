/**
 * @name Nested loops with identical loop variable
 * @description Detects nested for-loops where both loops use the same iteration variable,
 *              which can lead to unexpected behavior and reduced code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines if a for-loop uses the specified variable as its iteration variable
predicate loop_variable(For loopStmt, Variable var) { 
    loopStmt.getTarget().defines(var) 
}

// Identifies nested loops sharing the same iteration variable where the variable
// is referenced in the outer loop's scope (excluding the inner loop)
predicate variableUsedInNestedLoops(For nestedLoop, For enclosingLoop, Variable loopVar) {
    // Verify inner loop is directly nested within outer loop's body (not else clause)
    enclosingLoop.getBody().contains(nestedLoop) and
    
    // Confirm both loops use the same iteration variable
    loop_variable(nestedLoop, loopVar) and
    loop_variable(enclosingLoop, loopVar) and
    
    // Ensure the variable is actually used in the outer loop's scope
    exists(Name usageNode | 
        usageNode.uses(loopVar) and 
        enclosingLoop.contains(usageNode) and 
        not nestedLoop.contains(usageNode)
    )
}

// Find all instances of problematic nested loops with shared iteration variables
from For nestedLoop, For enclosingLoop, Variable loopVar
where variableUsedInNestedLoops(nestedLoop, enclosingLoop, loopVar)
select nestedLoop, 
    "Nested for-loop reuses iteration variable '" + loopVar.getId() + 
    "' from enclosing $@.", 
    enclosingLoop, 
    "for-loop"