/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that evaluate literal constants, 
 *              which may behave differently under compiler optimizations.
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

// Identify assert statements with literal constant test expressions
from Assert assertStmt, string constantValue
where
  /* Exclude assertions within test execution contexts */
  not assertStmt.getScope().getScope*() instanceof TestScope and
  /* Extract constant values from different literal types */
  exists(Expr testExpression | testExpression = assertStmt.getTest() |
    /* Handle integer literal constants */
    constantValue = testExpression.(IntegerLiteral).getN()
    or
    /* Handle string literal constants with quoted representation */
    constantValue = "\"" + testExpression.(StringLiteral).getS() + "\""
    or
    /* Handle named constants (True/False/None) */
    constantValue = testExpression.(NameConstant).toString()
  ) and
  /* Exclude assertions at the end of elif statement chains */
  not exists(If ifStatement | ifStatement.getElif().getAnOrelse() = assertStmt)
select assertStmt, "Assert of literal constant " + constantValue + "."