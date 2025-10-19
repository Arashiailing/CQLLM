/**
 * @name Comparison of constants
 * @description This query identifies expressions that compare two constant values,
 *              which always yield a fixed result. Such comparisons reduce code
 *              readability compared to directly using boolean values.
 * 
 *              For example, expressions like "5 == 5" or "3 > 10" should be
 *              replaced with "True" or "False" respectively, as they always
 *              evaluate to the same boolean value.
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

// Identify comparison expressions between constants
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // Extract left and right operands from the comparison operation
  constantComparison.compares(leftOperand, _, rightOperand)
  and
  // Verify that both operands are constants (e.g., literals, enum values)
  leftOperand.isConstant() and rightOperand.isConstant()
  and
  // Exclude comparisons used in assert statements
  // (assertions may need explicit expressions for documentation purposes)
  not exists(Assert assertStmt | assertStmt.getTest() = constantComparison)
select constantComparison, "常量比较表达式应替换为 'True' 或 'False'"