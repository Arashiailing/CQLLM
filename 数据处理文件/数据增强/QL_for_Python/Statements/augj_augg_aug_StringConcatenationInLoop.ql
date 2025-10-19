/**
 * @name String concatenation in loop
 * @description Detects inefficient string concatenation inside loops that causes quadratic performance.
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
 * Identifies string concatenation operations within loops.
 * This predicate matches binary expressions where:
 * - Operation is string addition (+)
 * - Occurs inside a loop construct
 * - Involves string variables that get repeatedly updated
 */
predicate string_concat_in_loop(BinaryExpr concatExpr) {
  // Step 1: Verify addition operation
  concatExpr.getOp() instanceof Add and
  // Step 2: Analyze variable relationships
  exists(SsaVariable originalVar, SsaVariable updatedVar, BinaryExprNode exprNode |
    // Link expression node to binary operation
    exprNode.getNode() = concatExpr and 
    // Establish variable definition chain
    originalVar = updatedVar.getAnUltimateDefinition() and
    // Verify string variable definition
    originalVar.getDefinition().(DefinitionNode).getValue() = exprNode and
    // Confirm variable usage in concatenation
    updatedVar.getAUse() = exprNode.getAnOperand() and
    // Validate string type operand
    exprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Detect problematic string concatenation in loops
from BinaryExpr concatExpr, Stmt loopStmt
where 
  // Match inefficient concatenation pattern
  string_concat_in_loop(concatExpr) and
  // Locate enclosing loop statement
  loopStmt.getASubExpression() = concatExpr
// Report with performance warning
select loopStmt, "String concatenation in a loop is quadratic in the number of iterations."