/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Identifies assertions that evaluate fixed literal values,
 *              which could lead to unexpected behavior with compiler optimizations.
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

// Identify assert statements checking literal constants outside test environments
from Assert assertStmt, string literalStringValue
where
  // Exclude assertions within test execution contexts
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Extract literal value from the assertion's test expression
  exists(Expr testExpression | testExpression = assertStmt.getTest() |
    // Handle integer literals
    literalStringValue = testExpression.(IntegerLiteral).getN()
    or
    // Handle string literals with quotation marks
    literalStringValue = "\"" + testExpression.(StringLiteral).getS() + "\""
    or
    // Handle boolean/None constants
    literalStringValue = testExpression.(NameConstant).toString()
  ) and
  // Exclude assertions at the end of conditional elif branches
  not exists(If ifStmt | ifStmt.getElif().getAnOrelse() = assertStmt)
select assertStmt, "Assert of literal constant " + literalStringValue + "."