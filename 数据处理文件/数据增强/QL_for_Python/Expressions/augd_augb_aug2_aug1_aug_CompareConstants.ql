/**
 * @name Comparison of constants
 * @description This rule identifies locations in code where two constant values are
 *              compared against each other. These comparisons always yield the same
 *              result at compile time, making them redundant. By replacing them with
 *              literal boolean values (True or False), code becomes clearer, less
 *              complex, and more maintainable. The analysis helps developers eliminate
 *              unnecessary constant comparisons for cleaner code.
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

// This query finds comparison operations between two constant expressions, excluding those inside assert statements
from Compare constantComparison, Expr leftConstantExpr, Expr rightConstantExpr
where
  // Check if both operands in the comparison are constant expressions
  leftConstantExpr.isConstant() and
  rightConstantExpr.isConstant() and
  // Ensure that the comparison operation has exactly two operands
  constantComparison.compares(leftConstantExpr, _, rightConstantExpr) and
  // Exclude comparisons that are part of assert statements
  not exists(Assert assertStatement | assertStatement.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."