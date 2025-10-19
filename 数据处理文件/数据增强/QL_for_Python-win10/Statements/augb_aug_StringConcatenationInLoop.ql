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
 * This predicate finds binary addition expressions where string concatenation
 * occurs in a loop context, with a variable being repeatedly updated.
 */
predicate string_concat_in_loop(BinaryExpr strConcatExpr) {
  // First, verify we're dealing with addition operation (string concatenation)
  strConcatExpr.getOp() instanceof Add and
  
  // Find the SSA variables involved in the concatenation operation
  exists(SsaVariable sourceVar, SsaVariable targetVar, BinaryExprNode concatExprNode |
    // Connect the expression node to our binary operation
    concatExprNode.getNode() = strConcatExpr and 
    // Establish the relationship between variable definition and usage
    sourceVar = targetVar.getAnUltimateDefinition()
  |
    // Verify that the operation defines the target string variable
    sourceVar.getDefinition().(DefinitionNode).getValue() = concatExprNode and
    // Check that the variable is used as an operand in the concatenation
    targetVar.getAUse() = concatExprNode.getAnOperand() and
    // Ensure at least one operand is of string type
    concatExprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Locate and report problematic string concatenation patterns
from BinaryExpr strConcatExpr, Stmt loopStmt
where 
  // Match our inefficient concatenation pattern
  string_concat_in_loop(strConcatExpr) and
  // Find the containing statement for this operation
  loopStmt.getASubExpression() = strConcatExpr
// Generate alert with performance impact information
select loopStmt, "String concatenation in a loop is quadratic in the number of iterations."