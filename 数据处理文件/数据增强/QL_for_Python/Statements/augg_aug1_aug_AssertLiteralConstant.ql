/**
 * @name Assertion on a literal constant
 * @description An assertion that checks a literal constant (like numbers, strings, or booleans) 
 *              might behave differently under compiler optimizations, potentially leading to 
 *              unexpected behavior.
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

from Assert assertion, string literalValue
where
  // Skip assertions in test code to prevent false positives
  not assertion.getScope().getScope*() instanceof TestScope and
  // Check if assertion contains literal constant expressions
  exists(Expr testExpr | 
    testExpr = assertion.getTest() and (
      // Case 1: Integer literals (e.g., assert 5)
      literalValue = testExpr.(IntegerLiteral).getN() or
      // Case 2: String literals with escaped quotes (e.g., assert "hello")
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Case 3: Name constants (None/True/False)
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Filter out assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + literalValue + "."