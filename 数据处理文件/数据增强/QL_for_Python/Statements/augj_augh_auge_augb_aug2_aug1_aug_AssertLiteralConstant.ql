/**
 * @name Literal Constant Assertion Check
 * @description Identifies assert statements that compare against literal constants such as integers, 
 *              strings, boolean values, or None. These assertions might exhibit unpredictable 
 *              behavior under compiler optimizations.
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
  // Exclude test files to reduce false positives
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Check if the assertion tests against a literal constant
  exists(Expr testedExpression | 
    testedExpression = assertStmt.getTest() and (
      // Case 1: Integer literal
      literalValue = testedExpression.(IntegerLiteral).getN() or
      // Case 2: String literal (with escaped quotes)
      literalValue = "\"" + testedExpression.(StringLiteral).getS() + "\"" or
      // Case 3: Boolean or None constants
      literalValue = testedExpression.(NameConstant).toString()
    )
  ) and
  // Exclude assertions at the end of elif chains
  not exists(If conditionalStatement | 
    conditionalStatement.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."