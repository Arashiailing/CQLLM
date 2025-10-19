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

// Identify comparison operations where both operands are constant expressions
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // Check if the operation is a comparison between two expressions
  constantComparison.compares(leftOperand, _, rightOperand) and
  // Verify both operands are constant expressions
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons within assert statements where explicit comparisons may be intentional
  not exists(Assert assertStatement | assertStatement.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."