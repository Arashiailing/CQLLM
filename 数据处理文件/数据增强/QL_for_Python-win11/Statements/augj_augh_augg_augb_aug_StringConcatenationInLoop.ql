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
 * Locates string concatenation operations that occur inside loop constructs.
 * This predicate finds binary addition expressions where strings are being concatenated
 * repeatedly within a loop, leading to performance issues due to string immutability.
 */
predicate string_concat_in_loop(BinaryExpr concatOperation) {
  // Verify the operation is an addition (used for string concatenation)
  concatOperation.getOp() instanceof Add and
  
  // Examine SSA variable relationships and expression structure
  exists(SsaVariable targetVar, SsaVariable sourceVar, BinaryExprNode operationNode |
    // Connect the AST node to our binary expression
    operationNode.getNode() = concatOperation and 
    // Establish the SSA variable definition chain
    targetVar = sourceVar.getAnUltimateDefinition()
  |
    // Confirm the target variable is defined by this concatenation operation
    targetVar.getDefinition().(DefinitionNode).getValue() = operationNode and
    // Ensure the source variable is used as an operand in the concatenation
    sourceVar.getAUse() = operationNode.getAnOperand() and
    // Validate that at least one operand is of string type
    operationNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Query to find and report inefficient string concatenation in loops
from BinaryExpr concatOperation, Stmt loopContainer
where 
  // Identify the problematic string concatenation pattern
  string_concat_in_loop(concatOperation) and
  // Determine the loop that contains this operation
  loopContainer.getASubExpression() = concatOperation
// Report the finding with an appropriate message
select loopContainer, "String concatenation in a loop is quadratic in the number of iterations."