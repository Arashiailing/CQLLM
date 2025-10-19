/**
 * @name Comparison of constants
 * @description Detects comparisons between constant values that always yield the same result.
 *              Such comparisons are redundant and should be replaced with literal boolean
 *              values (True/False) to improve code clarity and maintainability.
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
from Compare comparisonOp, Expr leftOperand, Expr rightOperand
where
  // Verify both operands are constant expressions
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Confirm the comparison involves exactly these two operands
  comparisonOp.compares(leftOperand, _, rightOperand) and
  // Exclude comparisons within assert statements
  not exists(Assert assertStmt | assertStmt.getTest() = comparisonOp)
select comparisonOp, "Comparison of constants; use 'True' or 'False' instead."