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
 * This predicate detects binary addition expressions where:
 * 1. The operation is string concatenation
 * 2. The operation occurs inside a loop
 * 3. One operand is a string variable that gets repeatedly updated
 */
predicate string_concat_in_loop(BinaryExpr stringConcatExpr) {
  // Verify the operation is string concatenation
  stringConcatExpr.getOp() instanceof Add and
  // Find variables involved in the concatenation
  exists(SsaVariable sourceVar, SsaVariable targetVar, BinaryExprNode concatExprNode |
    // Link the expression node to the binary operation
    concatExprNode.getNode() = stringConcatExpr and 
    // Track variable definition and usage relationship
    sourceVar = targetVar.getAnUltimateDefinition()
  |
    // Confirm the operation defines the string variable
    sourceVar.getDefinition().(DefinitionNode).getValue() = concatExprNode and
    // Verify the variable is used as an operand in concatenation
    targetVar.getAUse() = concatExprNode.getAnOperand() and
    // Ensure the operand is of string type
    concatExprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Identify problematic string concatenation locations
from BinaryExpr stringConcatExpr, Stmt loopStatement
where 
  // The operation matches our inefficient concatenation pattern
  string_concat_in_loop(stringConcatExpr) and
  // Locate the statement containing this operation
  loopStatement.getASubExpression() = stringConcatExpr
// Report the finding with performance warning
select loopStatement, "String concatenation in a loop is quadratic in the number of iterations."