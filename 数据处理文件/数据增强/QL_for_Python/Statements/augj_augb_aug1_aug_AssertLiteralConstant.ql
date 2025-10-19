/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that test literal constant values,
 *              which may behave differently when compiler optimizations are enabled.
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

from Assert assertionStatement, string constantLiteral
where
  // Exclude assertions in test contexts to reduce false positives
  not assertionStatement.getScope().getScope*() instanceof TestScope and
  // Extract the literal constant value from the assertion expression
  exists(Expr assertionExpression | 
    assertionExpression = assertionStatement.getTest() and (
      // Handle integer literals in assertions
      constantLiteral = assertionExpression.(IntegerLiteral).getN() or
      // Handle string literals with proper quote escaping
      constantLiteral = "\"" + assertionExpression.(StringLiteral).getS() + "\"" or
      // Handle boolean and None constants
      constantLiteral = assertionExpression.(NameConstant).toString()
    )
  ) and
  // Filter out assertions that are the final branch in an elif chain
  not exists(If conditionalBlock | 
    conditionalBlock.getElif().getAnOrelse() = assertionStatement
  )
select assertionStatement, "Assert of literal constant " + constantLiteral + "."