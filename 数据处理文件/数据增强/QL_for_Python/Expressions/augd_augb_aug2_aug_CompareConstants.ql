/**
 * @name Comparison of constants
 * @description Detects comparison operations involving two constant values that always evaluate to the same boolean result.
 *              Replacing such comparisons with their equivalent boolean literals (True or False) enhances code clarity.
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

// Find comparison expressions where both sides are constants
from Compare constCompareOp, Expr leftExpr, Expr rightExpr
where
  // Establish the comparison relationship between expressions
  constCompareOp.compares(leftExpr, _, rightExpr) and
  // Validate that both operands are constant expressions
  leftExpr.isConstant() and
  rightExpr.isConstant() and
  // Exclude comparisons within assert statements where explicitness may be desired
  not exists(Assert assertStmt | assertStmt.getTest() = constCompareOp)
select constCompareOp, "Comparison of constants; use 'True' or 'False' instead."