/**
 * @name Literal Constant in Assertion Check
 * @description This query identifies assertions that check against literal constants (such as
 *              numbers, strings, or booleans). Such assertions might exhibit different behavior
 *              when compiler optimizations are active, which could result in unexpected program
 *              execution.
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

from Assert assertStatement, string literalValue
where
  // Extract literal constant value from assertion test expression
  exists(Expr assertExpr | 
    assertExpr = assertStatement.getTest() and
    (
      // Process integer literals (convert to string without quotes)
      literalValue = assertExpr.(IntegerLiteral).getN().toString()
      or
      // Process string literals (preserve quotes in output)
      literalValue = "\"" + assertExpr.(StringLiteral).getS() + "\""
      or
      // Process name constants (None, True, False)
      literalValue = assertExpr.(NameConstant).toString()
    )
  )
  and
  // Filter out assertions within test scopes
  not assertStatement.getScope().getScope*() instanceof TestScope
  and
  // Filter out assertions at the end of elif chains
  not exists(If ifStatement | 
    ifStatement.getElif().getAnOrelse() = assertStatement
  )
select assertStatement, "Assert of literal constant " + literalValue + "."