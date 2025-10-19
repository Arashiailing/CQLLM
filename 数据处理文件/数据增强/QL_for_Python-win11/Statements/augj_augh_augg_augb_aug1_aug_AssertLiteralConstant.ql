/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that evaluate literal constants,
 *              which may behave unexpectedly under compiler optimizations.
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

from Assert assertionStmt, string constantValue
where
  // Exclude assertions within test scopes to reduce false positives
  not assertionStmt.getScope().getScope*() instanceof TestScope
  and
  // Filter out assertions positioned at the end of elif branches
  not exists(If ifStatement | 
    ifStatement.getElif().getAnOrelse() = assertionStmt
  )
  and
  // Identify assertions evaluating literal constants
  exists(Expr testedExpr | 
    testedExpr = assertionStmt.getTest() and (
      // Handle integer literals
      constantValue = testedExpr.(IntegerLiteral).getN()
      or
      // Process string literals with escaped quotes
      constantValue = "\"" + testedExpr.(StringLiteral).getS() + "\""
      or
      // Handle name constants (None, True, False)
      constantValue = testedExpr.(NameConstant).toString()
    )
  )
select assertionStmt, "Assert of literal constant " + constantValue + "."