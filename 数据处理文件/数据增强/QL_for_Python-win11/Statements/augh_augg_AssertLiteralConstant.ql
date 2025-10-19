/**
 * @name Assert statement tests truth value of literal constant
 * @description Detects assert statements that directly test literal constants,
 *              which may behave inconsistently under compiler optimizations.
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

from Assert assertion, string constantValue
where
  /* Filter out test case assertions */
  not assertion.getScope().getScope*() instanceof TestScope and
  /* Extract constant value from assertion's test expression */
  exists(Expr conditionExpr | conditionExpr = assertion.getTest() |
    /* Handle different literal constant types */
    (
      constantValue = conditionExpr.(IntegerLiteral).getN()
      or
      constantValue = "\"" + conditionExpr.(StringLiteral).getS() + "\""
      or
      constantValue = conditionExpr.(NameConstant).toString()
    )
  ) and
  /* Exclude assertions terminating elif chains */
  not exists(If ifBlock | ifBlock.getElif().getAnOrelse() = assertion)
select assertion, "Assert of literal constant " + constantValue + "."