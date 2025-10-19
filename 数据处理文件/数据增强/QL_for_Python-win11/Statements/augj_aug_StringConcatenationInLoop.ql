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
 * Locates string concatenation operations performed within loop constructs.
 * This predicate identifies binary addition expressions meeting these criteria:
 * 1. The expression represents string concatenation
 * 2. The expression is nested within a loop structure
 * 3. One operand is a string variable that undergoes repeated updates
 */
predicate inefficient_string_concat(BinaryExpr stringConcatExpr) {
  // Confirm the operation is string concatenation
  stringConcatExpr.getOp() instanceof Add and
  // Identify variables participating in the concatenation
  exists(SsaVariable sourceVariable, SsaVariable targetVariable, BinaryExprNode concatExprNode |
    // Associate the expression node with the binary operation
    concatExprNode.getNode() = stringConcatExpr and 
    // Establish the variable definition-usage relationship
    sourceVariable = targetVariable.getAnUltimateDefinition()
  |
    // Validate that the operation defines the string variable
    sourceVariable.getDefinition().(DefinitionNode).getValue() = concatExprNode and
    // Ensure the variable is utilized as an operand in concatenation
    targetVariable.getAUse() = concatExprNode.getAnOperand() and
    // Confirm the operand has string type
    concatExprNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Find locations of problematic string concatenation patterns
from BinaryExpr stringConcatExpr, Stmt parentStatement
where 
  // The expression matches our inefficient string concatenation pattern
  inefficient_string_concat(stringConcatExpr) and
  // Identify the statement that contains this operation
  parentStatement.getASubExpression() = stringConcatExpr
// Generate an alert with performance impact warning
select parentStatement, "String concatenation in a loop is quadratic in the number of iterations."