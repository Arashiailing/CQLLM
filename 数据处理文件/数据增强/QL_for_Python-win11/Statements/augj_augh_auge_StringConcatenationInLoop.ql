/**
 * @name String concatenation in loop
 * @description Identifies inefficient string concatenation within loops causing quadratic performance degradation.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Predicate using SSA variable relationships to detect performance-impacting string concatenation in loops
predicate inefficient_string_concat(BinaryExpr concatOperation) {
  // Verify the operation uses string concatenation (addition operator)
  concatOperation.getOp() instanceof Add and
  // Establish SSA variable relationships between definition and usage
  exists(SsaVariable sourceVar, SsaVariable targetVar, BinaryExprNode exprNode |
    // Map expression node to current concatenation operation
    exprNode.getNode() = concatOperation and 
    // Trace SSA variable definition chain
    sourceVar = targetVar.getAnUltimateDefinition()
  |
    // Confirm definition originates from this concatenation
    sourceVar.getDefinition().(DefinitionNode).getValue() = exprNode and
    // Verify variable is reused as operand in concatenation
    targetVar.getAUse() = exprNode.getAnOperand() and
    // Ensure at least one operand has string type
    exprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Query to identify statements containing problematic concatenation patterns
from BinaryExpr concatOperation, Stmt parentStatement
where 
  // Apply concatenation detection predicate
  inefficient_string_concat(concatOperation) and
  // Locate the statement containing the concatenation expression
  parentStatement.getASubExpression() = concatOperation
// Report findings with consistent output format
select parentStatement, "String concatenation in a loop is quadratic in the number of iterations."