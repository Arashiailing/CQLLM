/**
 * @name Comparison of constants
 * @description Identifies code locations where two constant values are compared.
 *              These comparisons always yield a fixed result at compile time,
 *              making them unnecessary. Replacing them with literal boolean
 *              values (True or False) improves code clarity, reduces complexity,
 *              and enhances maintainability. This analysis helps developers
 *              eliminate redundant constant comparisons for cleaner code.
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

// Finds comparison operations between two constant expressions, excluding those in assert statements
from Compare constantComparison, Expr leftConstantExpr, Expr rightConstantExpr
where
  // Verify the comparison structure and operands
  constantComparison.compares(leftConstantExpr, _, rightConstantExpr) and
  // Ensure both operands are constant expressions
  leftConstantExpr.isConstant() and
  rightConstantExpr.isConstant() and
  // Filter out comparisons that appear in assert statements
  not exists(Assert assertStatement | assertStatement.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."