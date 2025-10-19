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

// Identifies binary expressions performing string concatenation that may occur within loops.
// The loop context is inferred through SSA variable relationships rather than explicit loop detection.
predicate inefficient_string_concat(BinaryExpr stringConcatOp) {
  // Check if the operation is string concatenation (using the '+' operator)
  stringConcatOp.getOp() instanceof Add and
  // Analyze SSA variables to identify potential loop-based concatenation patterns
  exists(SsaVariable targetVar, SsaVariable sourceVar, BinaryExprNode concatNode |
    // Link the binary expression to its AST node representation
    concatNode.getNode() = stringConcatOp and 
    // Establish SSA variable relationship: targetVar is the ultimate definition of sourceVar
    targetVar = sourceVar.getAnUltimateDefinition() and
    // Verify the definition originates from this concatenation operation
    targetVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    // Confirm the variable is used as an operand in the concatenation
    sourceVar.getAUse() = concatNode.getAnOperand() and
    // Ensure the operand resolves to Python's string type
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Main query to locate statements containing inefficient string concatenation patterns
from BinaryExpr stringConcatOp, Stmt enclosingStmt
where 
  // Identify concatenation operations that match our inefficient pattern criteria
  inefficient_string_concat(stringConcatOp) and
  // Find the statement that contains the identified concatenation operation
  enclosingStmt.getASubExpression() = stringConcatOp
// Report findings with a description of the performance implications
select enclosingStmt, "String concatenation in a loop is quadratic in the number of iterations."