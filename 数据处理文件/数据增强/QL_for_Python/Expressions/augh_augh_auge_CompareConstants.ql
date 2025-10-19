/**
 * @name Comparison of constants
 * @description Identifies comparisons between two constant values in the code,
 *              which always yield a fixed result but are less readable than
 *              directly using True or False.
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

// Define variables for the comparison expression and its operands
from Compare constComparison, Expr lhsValue, Expr rhsValue
where
  // Ensure it's a comparison operation and get the left and right operands
  constComparison.compares(lhsValue, _, rhsValue)
  and
  // Check that both operands are constant values
  lhsValue.isConstant() and rhsValue.isConstant()
  and
  // Exclude constant comparisons used in assert statements (may have special purpose)
  not exists(Assert assertion | assertion.getTest() = constComparison)
select constComparison, "Comparison of constants; use 'True' or 'False' instead."