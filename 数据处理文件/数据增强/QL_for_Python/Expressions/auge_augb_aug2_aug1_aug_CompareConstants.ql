/**
 * @name Redundant constant comparison detection
 * @description Identifies code locations where two constant values are compared,
 *              which always yields a fixed result known at compile time. Such comparisons
 *              are unnecessary and should be replaced with literal boolean values (True/False)
 *              to improve code clarity, reduce complexity, and enhance maintainability.
 *              This analysis helps eliminate redundant constant comparisons for cleaner code.
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

// Identify comparison operations between constant expressions, excluding those in assert statements
from Compare constantComparison, Expr leftConstant, Expr rightConstant
where
  // Ensure comparison involves two operands
  constantComparison.compares(leftConstant, _, rightConstant) and
  // Verify both operands are constant expressions
  leftConstant.isConstant() and
  rightConstant.isConstant() and
  // Exclude comparisons within assert statements
  not exists(Assert assertion | assertion.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."