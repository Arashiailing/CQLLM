/**
 * @name Comparison of constants
 * @description This rule identifies comparisons between two constant expressions, which always yield a fixed result.
 *              Using the actual constant value (True or False) directly would improve code readability.
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

// Identify comparison operations where both operands are constant expressions,
// excluding those used within assert statements where explicit comparisons may be intentional
from Compare constExprComparison, Expr lhsExpr, Expr rhsExpr
where
  // Verify the operation is a comparison with constant operands on both sides
  constExprComparison.compares(lhsExpr, _, rhsExpr) and
  lhsExpr.isConstant() and
  rhsExpr.isConstant() and
  // Filter out comparisons within assert statements as they may serve specific documentation purposes
  not exists(Assert assertStmt | assertStmt.getTest() = constExprComparison)
select constExprComparison, "Comparison of constants; use 'True' or 'False' instead."