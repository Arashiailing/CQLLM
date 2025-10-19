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

// Predicate to identify string concatenation operations within loops
// using SSA variable relationships to detect performance issues
predicate string_concat_in_loop(BinaryExpr stringConcatExpr) {
  // Verify the operation is string concatenation (addition operator)
  stringConcatExpr.getOp() instanceof Add and
  // Identify SSA variables involved in the concatenation operation
  exists(SsaVariable definingVar, SsaVariable usingVar, BinaryExprNode addOperationNode |
    // Link the expression node to the current concatenation expression
    addOperationNode.getNode() = stringConcatExpr and 
    // Establish SSA variable relationship between definition and usage
    definingVar = usingVar.getAnUltimateDefinition()
  |
    // Confirm the definition originates from this concatenation
    definingVar.getDefinition().(DefinitionNode).getValue() = addOperationNode and
    // Verify the variable is used as an operand in the concatenation
    usingVar.getAUse() = addOperationNode.getAnOperand() and
    // Ensure at least one operand is a string type
    addOperationNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Query to locate statements containing problematic concatenation
from BinaryExpr stringConcatExpr, Stmt containingStmt
where 
  // Apply the concatenation detection predicate
  string_concat_in_loop(stringConcatExpr) and
  // Identify the statement containing the concatenation expression
  containingStmt.getASubExpression() = stringConcatExpr
// Report findings with consistent output format
select containingStmt, "String concatenation in a loop is quadratic in the number of iterations."