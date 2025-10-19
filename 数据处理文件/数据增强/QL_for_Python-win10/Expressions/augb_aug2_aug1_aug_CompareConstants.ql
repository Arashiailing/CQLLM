/**
 * @name Comparison of constants
 * @description Detects code locations where two constant values are being compared.
 *              Such comparisons produce a fixed result known at compile time, which
 *              makes them unnecessary. Replacing these with literal boolean values
 *              (True or False) enhances code clarity, reduces complexity, and improves
 *              maintainability. This analysis identifies redundant constant comparisons
 *              to help developers write cleaner code.
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

// Identifies comparison operations between two constant expressions, excluding those within assert statements
from Compare constExprComparison, Expr leftConstOperand, Expr rightConstOperand
where
  // Verify the comparison has two operands
  constExprComparison.compares(leftConstOperand, _, rightConstOperand) and
  // Confirm both operands are constant expressions
  leftConstOperand.isConstant() and
  rightConstOperand.isConstant() and
  // Filter out comparisons that appear in assert statements
  not exists(Assert assertStmt | assertStmt.getTest() = constExprComparison)
select constExprComparison, "Comparison of constants; use 'True' or 'False' instead."