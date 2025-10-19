/**
 * @name String concatenation in loop
 * @description Identifies inefficient string concatenation patterns within loops that cause quadratic performance degradation.
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
 * Detects string concatenation operations occurring within loop constructs.
 * This predicate identifies binary addition expressions where string concatenation
 * is performed in a loop context, involving repeated variable updates.
 */
predicate string_concat_in_loop(BinaryExpr binaryExpr) {
  // Confirm addition operation (string concatenation)
  binaryExpr.getOp() instanceof Add and
  
  // Analyze SSA variables and expression nodes involved
  exists(SsaVariable definedSsaVar, SsaVariable usedSsaVar, BinaryExprNode binaryExprNode |
    // Link expression node to current binary operation
    binaryExprNode.getNode() = binaryExpr and 
    // Establish variable definition relationship
    definedSsaVar = usedSsaVar.getAnUltimateDefinition()
  |
    // Verify operation defines target string variable
    definedSsaVar.getDefinition().(DefinitionNode).getValue() = binaryExprNode and
    // Confirm variable is used as concatenation operand
    usedSsaVar.getAUse() = binaryExprNode.getAnOperand() and
    // Ensure at least one operand has string type
    binaryExprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Identify and report inefficient string concatenation patterns
from BinaryExpr binaryExpr, Stmt enclosingLoop
where 
  // Detect problematic concatenation pattern
  string_concat_in_loop(binaryExpr) and
  // Locate containing loop statement
  enclosingLoop.getASubExpression() = binaryExpr
// Generate performance impact alert
select enclosingLoop, "String concatenation in a loop is quadratic in the number of iterations."