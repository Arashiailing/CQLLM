/**
 * @name Comparison of constants
 * @description Detects instances in code where two constant expressions are compared.
 *              Since the result of such comparisons is determined at compile time,
 *              directly using the resulting constant (True or False) would make
 *              the code more concise, readable, and maintainable. This query helps
 *              identify potentially unnecessary comparisons, thereby improving code quality.
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

// Identify comparison operations between two constant expressions, excluding those used in assert statements
from Compare constantComparison, Expr leftConstantExpr, Expr rightConstantExpr
where
  // Verify the operation is a comparison with constant operands
  constantComparison.compares(leftConstantExpr, _, rightConstantExpr) and
  // Check that both operands are constant expressions
  leftConstantExpr.isConstant() and
  rightConstantExpr.isConstant() and
  // Exclude comparisons used in assert statements where explicit comparisons may be needed
  not exists(Assert assertStmt | assertStmt.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."