/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that evaluate literal constants (e.g., numbers, strings, 
 *              None/True/False), which may behave inconsistently under compiler optimizations.
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

from Assert assertNode, string constantValue
where
  // Exclude assertions within test scopes to reduce false positives
  not assertNode.getScope().getScope*() instanceof TestScope and
  // Extract and validate literal constants in assertion expressions
  exists(Expr testExpr | 
    testExpr = assertNode.getTest() and (
      // Handle numeric literals
      constantValue = testExpr.(IntegerLiteral).getN() or
      // Handle string literals with escaped quotes
      constantValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Handle named constants (None, True, False)
      constantValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Filter out assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertNode
  )
select assertNode, "Assert of literal constant " + constantValue + "."