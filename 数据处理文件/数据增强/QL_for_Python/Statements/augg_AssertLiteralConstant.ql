/**
 * @name Assert statement tests the truth value of a literal constant
 * @description An assert statement testing a literal constant value may exhibit
 *              different behavior when optimizations are enabled.
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

from Assert assertStmt, string literalValue
where
  /* Exclude test case assertions */
  not assertStmt.getScope().getScope*() instanceof TestScope and
  exists(Expr testExpr | testExpr = assertStmt.getTest() |
    /* Extract literal value from different constant types */
    (
      literalValue = testExpr.(IntegerLiteral).getN()
      or
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\""
      or
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  /* Exclude assertions at the end of `elif` chains */
  not exists(If ifStmt | ifStmt.getElif().getAnOrelse() = assertStmt)
select assertStmt, "Assert of literal constant " + literalValue + "."