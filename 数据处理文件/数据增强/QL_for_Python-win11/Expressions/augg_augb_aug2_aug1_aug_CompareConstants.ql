import python

/**
 * @name Constant Value Comparison
 * @description Finds code locations where two constant values are compared against each other.
 *              These comparisons always yield the same result at compile time, rendering them
 *              redundant. By substituting such comparisons with literal boolean values (True/False),
 *              developers can enhance code readability, decrease complexity, and improve long-term
 *              maintainability. This analysis targets unnecessary constant comparisons to promote
 *              cleaner coding practices.
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

// Identify comparison operations between two constant expressions, excluding those in assert statements
from Compare constantComparison, Expr leftConstant, Expr rightConstant
where
  // Verify the comparison has two operands
  constantComparison.compares(leftConstant, _, rightConstant) and
  // Confirm both operands are constant expressions
  leftConstant.isConstant() and
  rightConstant.isConstant() and
  // Filter out comparisons that appear in assert statements
  not exists(Assert assertion | assertion.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."