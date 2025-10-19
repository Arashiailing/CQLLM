/**
 * @name Assertion of literal constant values
 * @description Detects assert statements that check against literal constants (integers, strings, booleans, None).
 *              Such assertions may behave inconsistently when compiler optimizations are enabled.
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
  // Filter out test files to minimize false positives
  not assertion.getScope().getScope*() instanceof TestScope and
  // Identify the expression being tested in the assertion
  exists(Expr assertionTestExpr | 
    assertionTestExpr = assertion.getTest() and (
      // Handle integer literal values
      constantValue = assertionTestExpr.(IntegerLiteral).getN() or
      // Handle string literals with properly escaped quotes
      constantValue = "\"" + assertionTestExpr.(StringLiteral).getS() + "\"" or
      // Handle name constants including None, True, and False
      constantValue = assertionTestExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions that appear at the end of elif statement chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constantValue + "."