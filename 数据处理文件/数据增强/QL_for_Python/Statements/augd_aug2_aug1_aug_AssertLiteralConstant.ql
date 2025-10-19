/**
 * @name Assertion of a literal constant value
 * @description Flags assert statements that verify literal constants (integers, strings, booleans).
 *              Such assertions may behave unpredictably under compiler optimizations.
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
  // Exclude test code assertions to minimize false positives
  not assertion.getScope().getScope*() instanceof TestScope and
  // Extract the asserted expression
  exists(Expr assertedExpression | 
    assertedExpression = assertion.getTest() and (
      // Case 1: Integer literal constants
      constantValue = assertedExpression.(IntegerLiteral).getN() or
      // Case 2: String literal constants (with escaped quotes)
      constantValue = "\"" + assertedExpression.(StringLiteral).getS() + "\"" or
      // Case 3: Name constants (None/True/False)
      constantValue = assertedExpression.(NameConstant).toString()
    )
  ) and
  // Filter out assertions at the end of elif branches
  not exists(If conditionalBlock | 
    conditionalBlock.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constantValue + "."