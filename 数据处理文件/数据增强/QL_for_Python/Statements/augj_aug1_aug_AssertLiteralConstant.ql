/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that evaluate literal constants, which may behave
 *              differently under compiler optimizations and indicate potential dead code.
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
  // Skip assertions within test frameworks to reduce false positives
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Extract literal constant value from assertion test expression
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and (
      // Process integer literals (e.g., assert 5)
      literalValue = testExpr.(IntegerLiteral).getN() or
      // Process string literals with escaped quotes (e.g., assert "foo")
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Process named constants (e.g., assert True)
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Filter out assertions at the end of elif chains (common debug placeholders)
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."