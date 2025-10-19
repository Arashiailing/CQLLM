/**
 * @name Comparison of constants
 * @description Identifies comparison operations where both operands are constant expressions.
 *              Such comparisons always evaluate to the same boolean value at compile time.
 *              Replacing them with their actual boolean result (True or False) improves
 *              code clarity, enhances readability, and facilitates maintainability. This
 *              analysis helps detect and eliminate redundant comparisons, thereby improving
 *              overall code quality.
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

// Identify comparison operations with constant expressions on both sides
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // Ensure the operation compares two expressions
  constantComparison.compares(leftOperand, _, rightOperand) and
  // Verify both operands are constant expressions
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons within assertion statements, as explicit comparisons may be intentional
  not exists(Assert assertStatement | assertStatement.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."