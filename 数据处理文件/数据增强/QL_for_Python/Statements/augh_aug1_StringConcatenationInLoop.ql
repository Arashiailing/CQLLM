/**
 * @name String concatenation in loop
 * @description Identifies inefficient string concatenation operations within loops, 
 *              which cause quadratic performance degradation due to repeated memory allocation.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Detects binary expressions performing string concatenation operations
predicate problematic_string_concat(BinaryExpr concatOperation) {
  // Verify operation is string concatenation (using addition operator)
  concatOperation.getOp() instanceof Add and
  // Analyze SSA variables involved in the concatenation
  exists(SsaVariable definedVar, SsaVariable usedVar, BinaryExprNode concatNode |
    // Map AST node to the binary expression
    concatNode.getNode() = concatOperation and 
    // Establish SSA variable relationship: definedVar is the ultimate source of usedVar
    definedVar = usedVar.getAnUltimateDefinition()
  |
    // Confirm definition originates from this concatenation operation
    definedVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    // Ensure variable is used as operand in concatenation
    usedVar.getAUse() = concatNode.getAnOperand() and
    // Validate operand resolves to Python string type
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Report statements containing inefficient string concatenation
from BinaryExpr concatOperation, Stmt containerStmt
where 
  // Identify concatenation operations matching our criteria
  problematic_string_concat(concatOperation) and
  // Locate the enclosing statement containing the operation
  containerStmt.getASubExpression() = concatOperation
// Output findings with performance impact explanation
select containerStmt, "String concatenation in a loop is quadratic in the number of iterations."