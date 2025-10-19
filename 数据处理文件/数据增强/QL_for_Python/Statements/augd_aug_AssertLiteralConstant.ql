/**
 * @name Assert statement tests the truth value of a literal constant
 * @description An assert statement testing a literal constant value may exhibit
 *              different behavior when optimizations are enabled.
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
  // Filter out assertions within test scopes to avoid false positives
  not assertion.getScope().getScope*() instanceof TestScope and
  // Extract the expression being tested in the assertion
  exists(Expr testedExpression | 
    testedExpression = assertion.getTest() and (
      // Case 1: Assertion contains an integer literal
      constantValue = testedExpression.(IntegerLiteral).getN() or
      // Case 2: Assertion contains a string literal (with quotes preserved)
      constantValue = "\"" + testedExpression.(StringLiteral).getS() + "\"" or
      // Case 3: Assertion contains a name constant (None, True, False)
      constantValue = testedExpression.(NameConstant).toString()
    )
  ) and
  // Exclude assertions that appear as the final statement in an elif chain
  not exists(If conditionalStmt | 
    conditionalStmt.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + constantValue + "."