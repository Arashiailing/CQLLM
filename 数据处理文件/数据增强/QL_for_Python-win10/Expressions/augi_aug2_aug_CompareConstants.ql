/**
 * @name Constant expression comparison
 * @description Detects comparisons between two constant values that always evaluate to the same result.
 *              Replacing such comparisons with their boolean equivalent (True or False) enhances code clarity.
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

// Identify comparison operations involving two constant expressions
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // Verify both operands in the comparison are constant values
  constantComparison.compares(leftOperand, _, rightOperand) and
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons within assert statements as they may serve documentation purposes
  not exists(Assert assertion | assertion.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."