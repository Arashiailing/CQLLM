/**
 * @name Constant expression comparison
 * @description Identifies comparisons involving two constant expressions that yield a predictable boolean outcome.
 *              Replacing such comparisons with their direct boolean result (True/False) enhances code readability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/comparison-of-constants
 */

import python

// Identify comparison operations where both operands are constant values,
// excluding those within assert statements where explicit comparisons may serve documentation purposes
from Compare constExprComparison, Expr leftOperand, Expr rightOperand
where
  // Verify that both sides of the comparison are constant expressions
  constExprComparison.compares(leftOperand, _, rightOperand) and
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons inside assert statements (may serve documentation purposes)
  not exists(Assert assertStmt | assertStmt.getTest() = constExprComparison)
select constExprComparison, "Comparison of constants; use 'True' or 'False' instead."