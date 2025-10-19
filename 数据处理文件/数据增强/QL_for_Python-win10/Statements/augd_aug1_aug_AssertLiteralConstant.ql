/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that check literal constants (integers, strings, booleans),
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

from Assert assertStmt, string literalValue
where
  // Skip assertions in test code to reduce false positives
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Extract literal constant values from the assertion's test expression
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and (
      // Integer literals (e.g., assert 1)
      literalValue = testExpr.(IntegerLiteral).getN() or
      // String literals (e.g., assert "hello")
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Boolean/None constants (e.g., assert True)
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Ignore assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."