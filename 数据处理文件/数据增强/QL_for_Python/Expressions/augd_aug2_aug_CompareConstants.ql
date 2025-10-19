/**
 * @name Comparison of constants
 * @description Detects comparisons between two constant expressions that always evaluate to a fixed result.
 *              Directly using the resulting boolean value (True/False) improves code clarity.
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

// Find comparison operations where both operands are constant values,
// excluding those within assert statements where explicit comparisons may be intentional
from Compare constantComparison, Expr leftValue, Expr rightValue
where
  // Ensure both sides of the comparison are constant expressions
  constantComparison.compares(leftValue, _, rightValue) and
  leftValue.isConstant() and
  rightValue.isConstant() and
  // Exclude comparisons inside assert statements (may serve documentation purposes)
  not exists(Assert assertion | assertion.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."