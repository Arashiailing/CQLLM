/**
 * @name Nested loops with same variable
 * @description Detects nested loops where both loops use identical iteration variables,
 *              which can lead to confusing behavior and potential bugs.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Predicate to determine if a loop uses a specific variable as its iteration target
predicate loop_variable(For loopStmt, Variable targetVar) { 
    loopStmt.getTarget().defines(targetVar) 
}

// Main query: Identify problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable sharedVar
where 
    // Ensure inner loop is directly nested within outer loop's body (not else clause)
    outerLoop.getBody().contains(innerLoop) and
    // Both loops must use the same iteration variable
    loop_variable(innerLoop, sharedVar) and
    loop_variable(outerLoop, sharedVar) and
    // Verify the variable is actually used in the outer loop (not just inner loop)
    exists(Name usageNode | 
        usageNode.uses(sharedVar) and 
        outerLoop.contains(usageNode) and 
        not innerLoop.contains(usageNode)
    )
select innerLoop, 
    "Nested for statement reuses iteration variable '" + sharedVar.getId() + 
    "' from enclosing $@.", 
    outerLoop, 
    "for statement"