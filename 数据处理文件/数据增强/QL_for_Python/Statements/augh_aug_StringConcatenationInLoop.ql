/**
 * @name String concatenation in loop
 * @description Detects inefficient string concatenation operations where a variable is repeatedly updated, potentially causing quadratic performance in loops.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

/**
 * Identifies string concatenation operations involving repeated variable updates.
 * This predicate detects binary addition expressions where:
 * 1. The operation performs string concatenation
 * 2. A string variable is both defined and used in the operation
 * 3. The variable is repeatedly updated through the operation
 */
predicate string_concat_in_loop(BinaryExpr concatOperation) {
  // Verify the operation is string concatenation
  concatOperation.getOp() instanceof Add and
  // Find SSA variables involved in the operation
  exists(SsaVariable defVar, SsaVariable useVar, BinaryExprNode exprNode |
    // Connect the expression node to the binary operation
    exprNode.getNode() = concatOperation and 
    // Establish variable definition-usage relationship
    defVar = useVar.getAnUltimateDefinition()
  |
    // Confirm the operation defines the string variable
    defVar.getDefinition().(DefinitionNode).getValue() = exprNode and
    // Verify the variable is used as an operand in concatenation
    useVar.getAUse() = exprNode.getAnOperand() and
    // Ensure at least one operand is of string type
    exprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Locate problematic string concatenation operations
from BinaryExpr concatOperation, Stmt containerStmt
where 
  // Match inefficient concatenation pattern
  string_concat_in_loop(concatOperation) and
  // Find the statement containing the operation
  containerStmt.getASubExpression() = concatOperation
// Report the performance issue
select containerStmt, "String concatenation with repeated variable updates may cause quadratic performance in loops."