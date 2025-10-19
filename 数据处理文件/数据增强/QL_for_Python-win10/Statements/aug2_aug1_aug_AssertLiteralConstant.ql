/**
 * @name Assertion of a literal constant value
 * @description This rule flags assert statements that check the truthiness of a literal constant.
 *              Such assertions may behave differently when compiler optimizations are applied.
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
  // Filter out assertions in test code to reduce false positives
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Check if the assertion tests a literal constant expression
  exists(Expr assertTest | 
    assertTest = assertStmt.getTest() and (
      // Integer literal case
      literalValue = assertTest.(IntegerLiteral).getN() or
      // String literal case with escaped quotes
      literalValue = "\"" + assertTest.(StringLiteral).getS() + "\"" or
      // Name constant case (None, True, False)
      literalValue = assertTest.(NameConstant).toString()
    )
  ) and
  // Exclude assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."