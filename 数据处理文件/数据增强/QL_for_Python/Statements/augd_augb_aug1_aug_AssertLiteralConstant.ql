/**
 * @name Assertion tests literal constant value
 * @description Assertions checking literal constants (integers, strings, booleans)
 *              may behave inconsistently under compiler optimizations.
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
  // Exclude assertions within test code to reduce false positives
  not assertion.getScope().getScope*() instanceof TestScope and
  // Identify literal constants in assertion test expressions
  exists(Expr testExpression | 
    testExpression = assertion.getTest() and (
      // Handle integer literals
      constantValue = testExpression.(IntegerLiteral).getN() or
      // Handle string literals with escaped quotes
      constantValue = "\"" + testExpression.(StringLiteral).getS() + "\"" or
      // Handle boolean/None constants
      constantValue = testExpression.(NameConstant).toString()
    )
  ) and
  // Filter assertions at the end of elif chains
  not exists(If ifStatement | 
    ifStatement.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constantValue + "."