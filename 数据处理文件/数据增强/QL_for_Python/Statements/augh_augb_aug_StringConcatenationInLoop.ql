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
 * Identifies inefficient string concatenation operations within loops.
 * This predicate detects binary addition expressions where strings are concatenated
 * in a loop context, causing quadratic performance degradation due to repeated
 * string recreation. The pattern involves a variable being repeatedly updated
 * through concatenation operations.
 */
predicate string_concat_in_loop(BinaryExpr concatOp) {
  // Verify the operation is string concatenation (addition)
  concatOp.getOp() instanceof Add and
  
  // Analyze SSA variables involved in the concatenation
  exists(SsaVariable originalVar, SsaVariable updatedVar, BinaryExprNode opNode |
    // Connect the expression node to our binary operation
    opNode.getNode() = concatOp and 
    // Establish SSA variable relationship: originalVar is the source definition
    originalVar = updatedVar.getAnUltimateDefinition()
  |
    // Verify the operation defines the target string variable
    originalVar.getDefinition().(DefinitionNode).getValue() = opNode and
    // Confirm the variable is used as an operand in concatenation
    updatedVar.getAUse() = opNode.getAnOperand() and
    // Ensure at least one operand is of string type
    opNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Identify and report inefficient string concatenation patterns
from BinaryExpr concatOp, Stmt loopContainer
where 
  // Match inefficient concatenation pattern
  string_concat_in_loop(concatOp) and
  // Find the loop statement containing this operation
  loopContainer.getASubExpression() = concatOp
// Generate alert with performance impact information
select loopContainer, "String concatenation in a loop is quadratic in the number of iterations."