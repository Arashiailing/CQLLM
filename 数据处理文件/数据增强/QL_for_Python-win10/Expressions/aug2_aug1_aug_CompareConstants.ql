/**
 * @name Comparison of constants
 * @description Identifies instances where two constant expressions are compared in code.
 *              The result of such comparisons is determined at compile time, making them
 *              redundant. Directly using constants (True or False) improves code
 *              simplicity, readability, and maintainability. This query helps detect
 *              unnecessary comparisons to enhance code quality.
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

// Finds comparison operations between two constant expressions, excluding those used in assert statements
from Compare constantComparison, Expr leftConstantExpr, Expr rightConstantExpr
where
  // Verify the comparison structure
  constantComparison.compares(leftConstantExpr, _, rightConstantExpr) and
  // Ensure both operands are constants
  leftConstantExpr.isConstant() and
  rightConstantExpr.isConstant() and
  // Exclude comparisons in assert statements (explicit comparisons may be needed there)
  not exists(Assert assertion | assertion.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."