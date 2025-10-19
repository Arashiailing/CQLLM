/**
 * @name String concatenation in loop
 * @description Detects inefficient string concatenation patterns within loops that cause quadratic performance degradation.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Identifies binary expressions performing string concatenation within loop constructs
predicate string_concat_in_loop(BinaryExpr concatOperation) {
  // Verify the operation uses addition (concatenation operator)
  concatOperation.getOp() instanceof Add and
  // Find SSA variables involved in the concatenation pattern
  exists(SsaVariable definitionVar, SsaVariable usageVar, BinaryExprNode concatNode |
    // Map the binary expression node to the current operation
    concatNode.getNode() = concatOperation and 
    // Establish SSA variable relationship: definitionVar is the ultimate definition of usageVar
    definitionVar = usageVar.getAnUltimateDefinition()
  |
    // Confirm the definition originates from the concatenation operation
    definitionVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    // Verify the usage occurs as an operand in the concatenation
    usageVar.getAUse() = concatNode.getAnOperand() and
    // Ensure at least one operand is of string type
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Query execution: Find statements containing problematic concatenation
from BinaryExpr concatOperation, Stmt enclosingStmt
where 
  // Apply the concatenation pattern detection
  string_concat_in_loop(concatOperation) and 
  // Establish containment relationship between statement and operation
  enclosingStmt.getASubExpression() = concatOperation
// Report findings with standardized message
select enclosingStmt, "String concatenation in a loop is quadratic in the number of iterations."