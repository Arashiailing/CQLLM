/**
 * @name Comparison of constants
 * @description Detects comparisons between constant values. These comparisons always yield
 *              the same result but are less readable than using boolean literals directly.
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

// Identify constant comparison expressions in the code
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // Verify the operation is a comparison with two operands
  constantComparison.compares(leftOperand, _, rightOperand) and
  // Ensure both operands are constant values
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons used in assert statements as they may be intentional
  not exists(Assert assertStmt | assertStmt.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."