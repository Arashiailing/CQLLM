/**
 * @name Assertion of a literal constant
 * @description An assertion that checks a literal constant (like 1, "hello", True) may be
 *              optimized away when compiler optimizations are enabled, potentially leading to
 *              unexpected behavior.
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

from Assert assertStmt, string constantValue
where
  // Skip assertions within test code
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Identify literal constants in assertion conditions
  exists(Expr assertionTest | 
    assertionTest = assertStmt.getTest() and (
      // Handle numeric literals
      constantValue = assertionTest.(IntegerLiteral).getN() or
      // Handle string literals with quotes
      constantValue = "\"" + assertionTest.(StringLiteral).getS() + "\"" or
      // Handle boolean/None constants
      constantValue = assertionTest.(NameConstant).toString()
    )
  ) and
  // Exclude assertions at the end of elif chains
  not exists(If conditionalBlock | 
    conditionalBlock.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + constantValue + "."