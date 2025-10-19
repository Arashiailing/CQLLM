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

// Helper predicate to verify if an expression performs string concatenation
private predicate isStringConcatenationOperation(BinaryExpr concatOperation) {
  // Check if the operation uses the addition operator for concatenation
  concatOperation.getOp() instanceof Add
}

// Helper predicate to analyze SSA variable relationships in concatenation operations
private predicate hasSsaLinkage(BinaryExpr concatOperation, SsaVariable sourceVar, SsaVariable targetVar) {
  exists(BinaryExprNode concatNodeAst |
    // Connect the binary expression with its AST node representation
    concatNodeAst.getNode() = concatOperation and
    // Establish SSA variable relationship where sourceVar is the ultimate definition of targetVar
    sourceVar = targetVar.getAnUltimateDefinition() and
    // Verify the definition originates from this concatenation operation
    sourceVar.getDefinition().(DefinitionNode).getValue() = concatNodeAst and
    // Confirm the variable is used as an operand in the concatenation
    targetVar.getAUse() = concatNodeAst.getAnOperand() and
    // Validate the operand resolves to Python's string type
    concatNodeAst.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Main predicate to identify binary expressions performing string concatenation within loops
predicate string_concat_in_loop(BinaryExpr concatOperation) {
  // First, verify this is a string concatenation operation
  isStringConcatenationOperation(concatOperation) and
  // Then check for SSA variable relationships indicating repeated concatenation
  exists(SsaVariable sourceVar, SsaVariable targetVar |
    hasSsaLinkage(concatOperation, sourceVar, targetVar)
  )
}

// Select statements containing inefficient string concatenation
from BinaryExpr concatOperation, Stmt containerStmt
where 
  // Identify concatenation operations meeting our criteria
  string_concat_in_loop(concatOperation) and
  // Locate the statement containing the problematic operation
  containerStmt.getASubExpression() = concatOperation
// Report findings with performance impact description
select containerStmt, "String concatenation in a loop is quadratic in the number of iterations."