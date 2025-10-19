/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that check literal constants (integers, strings, 
 *              or boolean values), which may behave inconsistently under compiler optimizations.
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
  // Filter out assertions within test scopes
  not assertion.getScope().getScope*() instanceof TestScope and
  // Identify literal constants in the assertion's test expression
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
  // Exclude assertions at the end of elif chains
  not exists(If conditionalStatement | 
    conditionalStatement.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constantValue + "."