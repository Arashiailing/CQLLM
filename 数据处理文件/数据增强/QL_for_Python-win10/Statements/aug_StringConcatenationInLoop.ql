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
 * Identifies string concatenation operations within loops.
 * This predicate detects binary addition expressions where:
 * 1. The operation is string concatenation
 * 2. The operation occurs inside a loop
 * 3. One operand is a string variable that gets repeatedly updated
 */
predicate string_concat_in_loop(BinaryExpr concatOperation) {
  // Verify the operation is string concatenation
  concatOperation.getOp() instanceof Add and
  // Find variables involved in the concatenation
  exists(SsaVariable definitionVar, SsaVariable usageVar, BinaryExprNode concatNode |
    // Link the expression node to the binary operation
    concatNode.getNode() = concatOperation and 
    // Track variable definition and usage relationship
    definitionVar = usageVar.getAnUltimateDefinition()
  |
    // Confirm the operation defines the string variable
    definitionVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    // Verify the variable is used as an operand in concatenation
    usageVar.getAUse() = concatNode.getAnOperand() and
    // Ensure the operand is of string type
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Identify problematic string concatenation locations
from BinaryExpr concatOperation, Stmt containingStmt
where 
  // The operation matches our inefficient concatenation pattern
  string_concat_in_loop(concatOperation) and
  // Locate the statement containing this operation
  containingStmt.getASubExpression() = concatOperation
// Report the finding with performance warning
select containingStmt, "String concatenation in a loop is quadratic in the number of iterations."