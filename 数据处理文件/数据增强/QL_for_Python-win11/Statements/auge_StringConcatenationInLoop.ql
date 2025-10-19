/**
 * @name String concatenation in loop
 * @description Detects inefficient string concatenation in loops causing quadratic performance.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Enhanced predicate to identify string concatenation operations within loops
predicate string_concat_in_loop(BinaryExpr concatExpr) {
  // Verify the operation is string concatenation (addition operator)
  concatExpr.getOp() instanceof Add and
  // Identify SSA variables involved in the concatenation operation
  exists(SsaVariable defVar, SsaVariable useVar, BinaryExprNode addNode |
    // Link the expression node to the current concatenation expression
    addNode.getNode() = concatExpr and 
    // Establish SSA variable relationship between definition and usage
    defVar = useVar.getAnUltimateDefinition()
  |
    // Confirm the definition originates from this concatenation
    defVar.getDefinition().(DefinitionNode).getValue() = addNode and
    // Verify the variable is used as an operand in the concatenation
    useVar.getAUse() = addNode.getAnOperand() and
    // Ensure at least one operand is a string type
    addNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Query to locate statements containing problematic concatenation
from BinaryExpr concatExpr, Stmt enclosingStmt
where 
  // Apply the enhanced concatenation detection
  string_concat_in_loop(concatExpr) and
  // Identify the statement containing the concatenation expression
  enclosingStmt.getASubExpression() = concatExpr
// Report findings with consistent output format
select enclosingStmt, "String concatenation in a loop is quadratic in the number of iterations."