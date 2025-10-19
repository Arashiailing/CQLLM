/**
 * @name String concatenation in loop
 * @description Detects string concatenation operations inside loops that cause quadratic performance degradation.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Identifies binary expressions that perform string concatenation within loop contexts
// Loop detection is accomplished through SSA variable relationships rather than explicit loop constructs
predicate inefficient_string_concat(BinaryExpr concatOperation) {
  // Verify the operation is string concatenation (using the addition operator)
  concatOperation.getOp() instanceof Add and
  // Examine the SSA variables involved in the concatenation operation
  exists(SsaVariable targetVar, SsaVariable originVar, BinaryExprNode concatAstNode |
    // Associate the binary expression with its corresponding AST node
    concatAstNode.getNode() = concatOperation and 
    // Establish the SSA relationship: targetVar represents the final definition of originVar
    targetVar = originVar.getAnUltimateDefinition() and
    // Confirm that the definition originates from this concatenation operation
    targetVar.getDefinition().(DefinitionNode).getValue() = concatAstNode and
    // Ensure the variable is utilized as an operand in the concatenation
    originVar.getAUse() = concatAstNode.getAnOperand() and
    // Validate that the operand resolves to Python's string type
    concatAstNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Primary query to identify statements containing inefficient string concatenation
from BinaryExpr concatOperation, Stmt containerStmt
where 
  // Locate concatenation operations that satisfy our criteria
  inefficient_string_concat(concatOperation) and
  // Determine the statement that encompasses the problematic operation
  containerStmt.getASubExpression() = concatOperation
// Report the performance concern with an appropriate message
select containerStmt, "String concatenation in a loop is quadratic in the number of iterations."