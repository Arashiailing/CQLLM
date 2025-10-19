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
 * Identifies string concatenation operations within loops that lead to quadratic performance.
 * This predicate matches binary addition expressions where:
 * 1. The operation performs string concatenation
 * 2. The operation is nested within a loop construct
 * 3. One operand is a string variable that gets repeatedly reassigned
 */
predicate problematic_string_concat_in_loop(BinaryExpr problematicConcatOp) {
  // Validate that the operation is a string concatenation (using addition operator)
  problematicConcatOp.getOp() instanceof Add and
  // Analyze SSA variable flow to detect repeated string concatenation pattern
  exists(SsaVariable originalVar, SsaVariable updatedVar, BinaryExprNode concatOperationNode |
    // Establish connection between expression node and binary operation
    concatOperationNode.getNode() = problematicConcatOp and 
    // Define SSA variable relationship between definition and subsequent usage
    originalVar = updatedVar.getAnUltimateDefinition()
  |
    // Verify the variable is defined by this concatenation operation
    originalVar.getDefinition().(DefinitionNode).getValue() = concatOperationNode and
    // Confirm the variable is used as an operand in the concatenation
    updatedVar.getAUse() = concatOperationNode.getAnOperand() and
    // Ensure the operand has string type
    concatOperationNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Identify statements containing inefficient string concatenation patterns
from BinaryExpr problematicConcatOp, Stmt containerStmt
where 
  // Match the problematic concatenation pattern
  problematic_string_concat_in_loop(problematicConcatOp) and
  // Find the enclosing statement that contains this operation
  containerStmt.getASubExpression() = problematicConcatOp
// Report the finding with performance impact explanation
select containerStmt, "String concatenation in a loop is quadratic in the number of iterations."