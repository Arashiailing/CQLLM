/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that check literal constant values,
 *              which may behave differently under compiler optimizations.
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

from Assert assertStmt, string literalValue
where
  // Exclude assertions within test scopes to focus on production code
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Identify and extract literal constant values from the assertion's test expression
  exists(Expr testExpression | 
    testExpression = assertStmt.getTest() and (
      // Handle integer literals
      literalValue = testExpression.(IntegerLiteral).getN() or
      // Handle string literals with proper quote formatting
      literalValue = "\"" + testExpression.(StringLiteral).getS() + "\"" or
      // Handle boolean and None constants
      literalValue = testExpression.(NameConstant).toString()
    )
  ) and
  // Filter out assertions that appear at the end of elif branches
  not exists(If conditionalBlock | 
    conditionalBlock.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."