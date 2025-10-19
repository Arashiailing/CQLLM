/**
 * @name String concatenation in loop
 * @description Detects inefficient string concatenation inside loops causing quadratic performance.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Predicate to identify binary expressions that perform string concatenation within loops
// The "in loop" aspect is detected through SSA variable relationships rather than explicit loop checks
predicate string_concat_in_loop(BinaryExpr concatenationExpr) {
  // First, verify the operation is string concatenation (using the addition operator)
  concatenationExpr.getOp() instanceof Add and
  // Then, find SSA variables involved in the concatenation operation
  exists(SsaVariable definedVar, SsaVariable usedVar, BinaryExprNode concatOperationNode |
    // Connect the binary expression to its AST node representation
    concatOperationNode.getNode() = concatenationExpr and 
    // Establish the SSA variable relationship: definedVar is the ultimate definition of usedVar
    definedVar = usedVar.getAnUltimateDefinition() and
    // Ensure the definition originates from this concatenation operation
    definedVar.getDefinition().(DefinitionNode).getValue() = concatOperationNode and
    // Confirm the variable is used as an operand in the concatenation
    usedVar.getAUse() = concatOperationNode.getAnOperand() and
    // Validate that the operand resolves to Python's string type
    concatOperationNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Main query to select statements containing inefficient string concatenation
from BinaryExpr concatenationExpr, Stmt containerStmt
where 
  // Identify concatenation operations that meet our criteria
  string_concat_in_loop(concatenationExpr) and
  // Find the statement that contains the problematic operation
  containerStmt.getASubExpression() = concatenationExpr
// Report the findings with a description of the performance impact
select containerStmt, "String concatenation in a loop is quadratic in the number of iterations."