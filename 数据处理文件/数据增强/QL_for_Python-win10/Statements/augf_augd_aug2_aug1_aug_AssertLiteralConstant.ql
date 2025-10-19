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

from Assert assertStmt, string literalValue
where
  // Filter out assertions within test code to reduce false positives
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Extract the expression being tested in the assertion
  exists(Expr testedExpr | 
    testedExpr = assertStmt.getTest() and (
      // Case 1: Integer literal constants
      literalValue = testedExpr.(IntegerLiteral).getN() or
      // Case 2: String literal constants (with escaped quotes)
      literalValue = "\"" + testedExpr.(StringLiteral).getS() + "\"" or
      // Case 3: Name constants (None/True/False)
      literalValue = testedExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions located at the end of elif branches
  not exists(If conditionalStmt | 
    conditionalStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."