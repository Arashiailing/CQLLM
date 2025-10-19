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
predicate string_concat_in_loop(BinaryExpr concatExpr) {
  // Verify addition operation (string concatenation)
  concatExpr.getOp() instanceof Add and
  
  // Analyze SSA variables and expression nodes involved
  exists(SsaVariable definedVar, SsaVariable usedVar, BinaryExprNode exprNode |
    // Connect expression node to current binary operation
    exprNode.getNode() = concatExpr and 
    // Establish variable definition relationship
    definedVar = usedVar.getAnUltimateDefinition()
  |
    // Verify operation defines target string variable
    definedVar.getDefinition().(DefinitionNode).getValue() = exprNode and
    // Confirm variable is used as concatenation operand
    usedVar.getAUse() = exprNode.getAnOperand() and
    // Ensure at least one operand has string type
    exprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Detect and report problematic string concatenation patterns
from BinaryExpr concatExpr, Stmt loopContainer
where 
  // Identify inefficient concatenation pattern
  string_concat_in_loop(concatExpr) and
  // Locate containing loop statement
  loopContainer.getASubExpression() = concatExpr
// Generate performance impact alert
select loopContainer, "String concatenation in a loop is quadratic in the number of iterations."