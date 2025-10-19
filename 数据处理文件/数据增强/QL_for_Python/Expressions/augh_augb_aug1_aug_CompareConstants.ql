/**
 * @name Comparison of constants
 * @description Detects comparison operations where both operands are constant expressions.
 *              These comparisons always evaluate to the same boolean value at compile time.
 *              Substituting them with their actual boolean result (True or False) enhances
 *              code clarity, improves readability, and facilitates maintainability. This
 *              analysis helps identify and eliminate redundant comparisons to improve
 *              overall code quality.
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

// Find comparison operations between constant expressions that are not part of assertions
from Compare constExprComparison, Expr leftConstExpr, Expr rightConstExpr
where
  // Check if the operation is a comparison with constant expressions on both sides
  constExprComparison.compares(leftConstExpr, _, rightConstExpr) and
  // Verify that both operands are indeed constant expressions
  leftConstExpr.isConstant() and
  rightConstExpr.isConstant() and
  // Exclude comparisons within assertion statements, as explicit comparisons may be intentional there
  not exists(Assert assertionStmt | assertionStmt.getTest() = constExprComparison)
select constExprComparison, "Comparison of constants; use 'True' or 'False' instead."