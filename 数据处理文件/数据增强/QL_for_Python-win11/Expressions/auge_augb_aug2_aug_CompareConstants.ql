/**
 * @name Comparison of constants
 * @description Identifies comparison operations between two constant expressions that always yield a fixed result.
 *              Direct use of the constant boolean value (True or False) would improve code readability and maintainability.
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

// Identify comparison operations between constant expressions
from Compare comparisonNode, Expr lhs, Expr rhs
where
  // Verify the operation compares two expressions
  comparisonNode.compares(lhs, _, rhs) and
  // Ensure both operands are constant expressions
  lhs.isConstant() and
  rhs.isConstant() and
  // Exclude comparisons in assert statements where explicit checks may be intentional
  not exists(Assert assertion | assertion.getTest() = comparisonNode)
select comparisonNode, "Comparison of constants; use 'True' or 'False' instead."