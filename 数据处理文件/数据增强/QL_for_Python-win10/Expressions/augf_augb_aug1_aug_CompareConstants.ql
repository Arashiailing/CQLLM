/**
 * @name Comparison of constants
 * @description Detects comparisons between two constant expressions. These comparisons
 *              yield predetermined results at compile time. Replacing them with their
 *              actual boolean values (True or False) enhances code clarity, readability,
 *              and maintainability. This query identifies unnecessary comparisons
 *              to improve overall code quality.
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

// Find comparison operations between constant expressions, excluding those in assertions
from Compare constExprComparison, Expr leftConstExpr, Expr rightConstExpr
where
  // Check if the operation is a comparison with constant expressions on both sides
  constExprComparison.compares(leftConstExpr, _, rightConstExpr) and
  // Verify that both operands are constant expressions
  leftConstExpr.isConstant() and
  rightConstExpr.isConstant() and
  // Exclude comparisons within assertion statements (explicit comparisons may be intentional there)
  not exists(Assert assertStatement | assertStatement.getTest() = constExprComparison)
select constExprComparison, "Comparison of constants; use 'True' or 'False' instead."