/**
 * @name String concatenation in loop
 * @description Identifies string concatenation operations within loops that lead to quadratic performance.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Identifies binary expressions performing string concatenation in loop contexts
// Loop detection is achieved through SSA variable relationships rather than direct loop constructs
predicate inefficient_string_concat(BinaryExpr stringConcatExpr) {
  // Check if the operation is string concatenation (addition operator)
  stringConcatExpr.getOp() instanceof Add and
  // Analyze SSA variables involved in the concatenation
  exists(SsaVariable resultVar, SsaVariable sourceVar, BinaryExprNode concatNode |
    // Link the binary expression to its AST node
    concatNode.getNode() = stringConcatExpr and 
    // Establish SSA relationship: resultVar is the ultimate definition of sourceVar
    resultVar = sourceVar.getAnUltimateDefinition() and
    // Verify the definition comes from this concatenation operation
    resultVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    // Confirm the variable is used as an operand in the concatenation
    sourceVar.getAUse() = concatNode.getAnOperand() and
    // Validate the operand resolves to Python's string type
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Main query to detect statements with inefficient string concatenation
from BinaryExpr stringConcatExpr, Stmt enclosingStmt
where 
  // Find concatenation operations matching our criteria
  inefficient_string_concat(stringConcatExpr) and
  // Identify the statement containing the problematic operation
  enclosingStmt.getASubExpression() = stringConcatExpr
// Report the performance issue with an appropriate message
select enclosingStmt, "String concatenation in a loop is quadratic in the number of iterations."