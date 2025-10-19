/**
 * @name Assertion of a literal constant value
 * @description This rule flags assert statements that check the truthiness of a literal constant.
 *              Such assertions may behave differently when compiler optimizations are applied.
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
  // Exclude assertions in test code to reduce false positives
  not assertion.getScope().getScope*() instanceof TestScope and
  // Identify assertions testing literal constants (integer/string/name)
  exists(Expr testExpression | 
    testExpression = assertion.getTest() and (
      // Handle integer literals
      constantValue = testExpression.(IntegerLiteral).getN() or
      // Handle string literals with escaped quotes
      constantValue = "\"" + testExpression.(StringLiteral).getS() + "\"" or
      // Handle name constants (None, True, False)
      constantValue = testExpression.(NameConstant).toString()
    )
  ) and
  // Exclude assertions terminating elif chains
  not exists(If ifBlock | 
    ifBlock.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constantValue + "."