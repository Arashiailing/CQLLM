/**
 * @name Assertion Checks Using Literal Constants
 * @description Identifies assertions that compare against literal constants (numbers, strings, 
 *              or booleans). These assertions may behave differently under compiler optimizations,
 *              potentially leading to unexpected program behavior.
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

from Assert assertion, string constValue
where
  // Extract literal constant value from assertion test expression
  exists(Expr testExpr | 
    testExpr = assertion.getTest() and
    (
      // Handle integer literals (convert to string representation)
      constValue = testExpr.(IntegerLiteral).getN().toString()
      or
      // Handle string literals (preserve quotes in output)
      constValue = "\"" + testExpr.(StringLiteral).getS() + "\""
      or
      // Handle name constants (None, True, False)
      constValue = testExpr.(NameConstant).toString()
    )
  )
  and
  // Filter out assertions within test scopes
  not assertion.getScope().getScope*() instanceof TestScope
  and
  // Filter out assertions at the end of elif chains
  not exists(If conditional | 
    conditional.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constValue + "."