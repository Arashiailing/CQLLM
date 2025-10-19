/**
 * @name Assertion of a literal constant value
 * @description Identifies assert statements that verify literal constants (integers, strings, 
 *              or name constants like None/True/False). Such assertions may behave inconsistently 
 *              under compiler optimizations.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/assert-literal-constant
 */

import python
import semmle.python.filters.Tests

from Assert stmt, string literalValue
where
  // Exclude test code to minimize false positives
  not stmt.getScope().getScope*() instanceof TestScope and
  // Extract literal value from assertion condition
  exists(Expr conditionExpr | 
    conditionExpr = stmt.getTest() and (
      // Integer literal case
      literalValue = conditionExpr.(IntegerLiteral).getN() or
      // String literal case (with escaped quotes)
      literalValue = "\"" + conditionExpr.(StringLiteral).getS() + "\"" or
      // Name constant case (None/True/False)
      literalValue = conditionExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions terminating elif chains
  not exists(If ifNode | 
    ifNode.getElif().getAnOrelse() = stmt
  )
select stmt, "Assert of literal constant " + literalValue + "."