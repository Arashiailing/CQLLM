/**
 * @name String concatenation in loop
 * @description Detects string concatenation operations within loops, which have quadratic performance characteristics.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Predicate to identify string concatenation operations within loops
// by analyzing binary expressions and SSA variables
predicate string_concat_in_loop(BinaryExpr binaryExpr) {
  // Verify the operation is an addition
  binaryExpr.getOp() instanceof Add and
  // Check if it involves string concatenation within a loop context
  // by examining SSA variable relationships
  exists(SsaVariable definedVar, SsaVariable usedVar, BinaryExprNode concatNode |
    // Link the binary expression node to the current binary expression
    concatNode.getNode() = binaryExpr and 
    // Establish SSA variable relationship: definedVar is the ultimate definition of usedVar
    definedVar = usedVar.getAnUltimateDefinition() and
    // Ensure the definition of definedVar is the current concatenation operation
    definedVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    // Verify usedVar is used as an operand in the concatenation
    usedVar.getAUse() = concatNode.getAnOperand() and
    // Confirm the operand points to the string class
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Select statements containing string concatenation in loops
from BinaryExpr binaryExpr, Stmt statement
// Filter for binary expressions that are string concatenations in loops
// and are contained within the selected statement
where string_concat_in_loop(binaryExpr) and statement.getASubExpression() = binaryExpr
// Output the statement with a performance warning
select statement, "String concatenation in a loop is quadratic in the number of iterations."