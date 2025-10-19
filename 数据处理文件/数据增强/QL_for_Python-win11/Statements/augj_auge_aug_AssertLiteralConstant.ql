/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that check literal constant values,
 *              which may lead to inconsistent behavior when compiler optimizations are enabled.
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
  // Step 1: Filter out assertions we don't want to report
  not assertStmt.getScope().getScope*() instanceof TestScope and
  not exists(If ifStatement | ifStatement.getElif().getAnOrelse() = assertStmt) and
  
  // Step 2: Extract and process the assertion's test expression
  exists(Expr testExpression | 
    testExpression = assertStmt.getTest() and
    // Step 3: Determine the literal value based on the expression type
    (
      // Integer literals
      literalValue = testExpression.(IntegerLiteral).getN() or
      // String literals with enclosing quotes
      literalValue = "\"" + testExpression.(StringLiteral).getS() + "\"" or
      // Named constants (None, True, False)
      literalValue = testExpression.(NameConstant).toString()
    )
  )
select assertStmt, "Assert of literal constant " + literalValue + "."