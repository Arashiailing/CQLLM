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

// Find assert statements that check literal constant values
from Assert assertion, string literalValue
where
  /* Filter out assertions within test code execution environments */
  not assertion.getScope().getScope*() instanceof TestScope and
  /* Extract the literal value from various constant types in the assertion expression */
  exists(Expr assertExpr | assertExpr = assertion.getTest() |
    /* Process integer literals directly */
    literalValue = assertExpr.(IntegerLiteral).getN()
    or
    /* Format string literals with quotation marks */
    literalValue = "\"" + assertExpr.(StringLiteral).getS() + "\""
    or
    /* Handle boolean and None constants by converting to string */
    literalValue = assertExpr.(NameConstant).toString()
  ) and
  /* Eliminate assertions at the end of conditional elif branches */
  not exists(If conditionalStmt | conditionalStmt.getElif().getAnOrelse() = assertion)
select assertion, "Assert of literal constant " + literalValue + "."