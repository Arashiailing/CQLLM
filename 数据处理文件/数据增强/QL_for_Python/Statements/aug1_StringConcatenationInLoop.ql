/**
 * @name String concatenation in loop
 * @description Detects inefficient string concatenation inside loops causing quadratic performance.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Identifies binary expressions performing string concatenation within loops
predicate string_concat_in_loop(BinaryExpr binaryExpr) {
  // Verify the operation is string concatenation (addition operator)
  binaryExpr.getOp() instanceof Add and
  // Find SSA variables involved in the concatenation operation
  exists(SsaVariable defVar, SsaVariable useVar, BinaryExprNode concatNode |
    // Link the binary expression to its AST node representation
    concatNode.getNode() = binaryExpr and 
    // Establish SSA variable relationship: defVar is the ultimate definition of useVar
    defVar = useVar.getAnUltimateDefinition()
  |
    // Ensure the definition originates from this concatenation operation
    defVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    // Confirm the variable is used as an operand in the concatenation
    useVar.getAUse() = concatNode.getAnOperand() and
    // Validate the operand resolves to Python's string type
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Select statements containing inefficient string concatenation
from BinaryExpr binaryExpr, Stmt enclosingStmt
where 
  // Identify concatenation operations meeting our criteria
  string_concat_in_loop(binaryExpr) and
  // Locate the statement containing the problematic operation
  enclosingStmt.getASubExpression() = binaryExpr
// Report findings with performance impact description
select enclosingStmt, "String concatenation in a loop is quadratic in the number of iterations."