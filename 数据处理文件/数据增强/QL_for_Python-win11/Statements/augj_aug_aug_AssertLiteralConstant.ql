/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Identifies assert statements that evaluate literal constants,
 *              which may behave unexpectedly under compiler optimizations.
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

// Find assert statements with literal constant test expressions
from Assert assertion, string literalValue
where
  /* Exclude assertions within test execution contexts */
  not assertion.getScope().getScope*() instanceof TestScope and
  /* Extract constant values from different literal types */
  exists(Expr testExpr | testExpr = assertion.getTest() |
    /* Handle integer literal constants */
    literalValue = testExpr.(IntegerLiteral).getN()
    or
    /* Handle string literal constants with quoted representation */
    literalValue = "\"" + testExpr.(StringLiteral).getS() + "\""
    or
    /* Handle named constants (True/False/None) */
    literalValue = testExpr.(NameConstant).toString()
  ) and
  /* Exclude assertions at the end of elif statement chains */
  not exists(If ifStmt | ifStmt.getElif().getAnOrelse() = assertion)
select assertion, "Assert of literal constant " + literalValue + "."