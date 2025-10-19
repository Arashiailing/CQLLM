/**
 * @name Assertion statement evaluates a literal constant
 * @description An assertion that evaluates a literal constant might behave
 *              differently when compiler optimizations are turned on.
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
  // Exclude assertions within test frameworks to minimize false positives
  not assertion.getScope().getScope*() instanceof TestScope and
  // Check if the assertion's test expression is a literal constant
  exists(Expr testedExpression | 
    testedExpression = assertion.getTest() and (
      // Handle integer literal constants
      constantValue = testedExpression.(IntegerLiteral).getN() or
      // Handle string literal constants with escaped quotes
      constantValue = "\"" + testedExpression.(StringLiteral).getS() + "\"" or
      // Handle boolean and None constants
      constantValue = testedExpression.(NameConstant).toString()
    )
  ) and
  // Filter out assertions that are part of an elif chain's final branch
  not exists(If conditional | 
    conditional.getElif().getAnOrelse() = assertion
  )
select assertion, "Assertion of literal constant " + constantValue + "."