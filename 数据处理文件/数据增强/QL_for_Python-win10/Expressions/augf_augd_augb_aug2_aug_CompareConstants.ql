/**
 * @name Comparison of constants
 * @description Detects comparisons between two constant values that always yield the same boolean result. 
 *              Such comparisons can be replaced with their equivalent boolean literals (True or False) 
 *              to improve code clarity.
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

// Identify comparison operations with constant operands
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // Establish comparison relationship between operands
  constantComparison.compares(leftOperand, _, rightOperand) and
  // Validate both operands are constant expressions
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons in assert statements where explicitness is intentional
  not exists(Assert assertStmt | assertStmt.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."