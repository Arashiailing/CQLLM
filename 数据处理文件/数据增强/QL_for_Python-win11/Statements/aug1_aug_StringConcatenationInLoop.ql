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
 * Identifies string concatenation operations within loops that lead to quadratic performance.
 * This predicate matches binary addition expressions where:
 * 1. The operation performs string concatenation
 * 2. The operation is nested within a loop construct
 * 3. One operand is a string variable that gets repeatedly reassigned
 */
predicate string_concat_in_loop(BinaryExpr inefficientConcatExpr) {
  // Confirm the operation is a string concatenation (addition operator)
  inefficientConcatExpr.getOp() instanceof Add and
  // Analyze variable flow to detect repeated string concatenation pattern
  exists(SsaVariable sourceVar, SsaVariable targetVar, BinaryExprNode concatExprNode |
    // Connect the expression node to our binary operation
    concatExprNode.getNode() = inefficientConcatExpr and 
    // Establish SSA variable relationship between definition and usage
    sourceVar = targetVar.getAnUltimateDefinition()
  |
    // Verify the variable is defined by this concatenation operation
    sourceVar.getDefinition().(DefinitionNode).getValue() = concatExprNode and
    // Confirm the variable is used as an operand in the concatenation
    targetVar.getAUse() = concatExprNode.getAnOperand() and
    // Ensure the operand has string type
    concatExprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Locate statements containing problematic string concatenation patterns
from BinaryExpr inefficientConcatExpr, Stmt enclosingStatement
where 
  // Match the inefficient concatenation pattern
  string_concat_in_loop(inefficientConcatExpr) and
  // Find the statement that contains this operation
  enclosingStatement.getASubExpression() = inefficientConcatExpr
// Report the finding with performance impact explanation
select enclosingStatement, "String concatenation in a loop is quadratic in the number of iterations."