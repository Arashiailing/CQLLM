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

// Identify comparison operations between constant expressions
from Compare constantCompare, Expr leftOperand, Expr rightOperand
where
  // Verify comparison involves two constant operands
  constantCompare.compares(leftOperand, _, rightOperand) and
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons within assert statements
  not exists(Assert assertion | assertion.getTest() = constantCompare)
select constantCompare, "Comparison of constants; use 'True' or 'False' instead."